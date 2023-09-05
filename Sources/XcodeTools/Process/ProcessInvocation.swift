import Foundation
#if canImport(System)
import System
#else
import SystemPackage
#endif

import StreamReader

import CMacroExports
import SignalHandling
import Utils

#if canImport(eXtenderZ)
import CNSTaskHelptender
import eXtenderZ
#endif



/**
 A type representing a “process invocation,” that is all of the different parameters needed to launch a new sub-process.
 This type is also an `AsyncSequence`.
 
 The element of the async sequence is ``RawLineWithSource``, which represent a raw line of process output, with the source fd from which the line comes from.
 The sequence can throw
  before the first output line is issued because the process failed to launch,
  while receiving lines because there was an I/O error,
  or after all the lines have been received because the process had an unexpected termination (the expected terminations are customizable).
 
 When launched, the process will be launched in its own PGID.
 Which means, if your process is launched in a Terminal,
  then you spawn a process using this object,
  then the user types `Ctrl-C`,
 your process will be killed,
  but the process you launched won’t be.
 
 However, you have an option to forward some signals to the processes you spawn using this object.
 Some signals are forwarded by default.
 
 IMHO the signal forwarding method, though a bit more complex (in this case, a lot of the complexity is hidden by this object),
 is better than using the same PGID than the parent for the child.
 In a shell, if a long running process is launched from a bash script, and said bash script is killed using a signal
 (but from another process sending a signal, not from the tty), the child won’t be killed!
 Using signal forwarding, it will.
 
 Some interesting links:
 - [The TTY demystified](http://www.linusakesson.net/programming/tty/)
 - [SIGTTIN / SIGTTOU Deep Dive](http://curiousthing.org/sigttin-sigttou-deep-dive-linux)
 - [Swift Process class source code](https://github.com/apple/swift-corelibs-foundation/blob/swift-5.3.3-RELEASE/Sources/Foundation/Process.swift)
 
 - Important: For technical reasons (and design choice), if file descriptors to send is not empty, the process will be launched _via_ the `xct` executable.
 
 - Note: We use `Process` to spawn the process.
 This is why the process is launched in its own PGID
 and why we have to use `xct` to launch it to be able to pass other file descriptors than stdin/stdout/stderr to it.
 
 One day we might rewrite this function using `posix_spawn` directly…
 
 - Note: On Linux, the PGID stuff is not true up to Swift 5.3.3 (currently in production!)
 It is true on the `main` branch though (2021-04-01).
 
 - Important: All of the `additionalOutputFileDescriptors` are closed when the end of their respective stream are reached
 (i.e. the function takes “ownership” of the file descriptors).
 Maybe later we’ll add an option not to close at end of the stream.
 Additionally on Linux the fds will be set non-blocking
 (clients should not care as they have given up ownership of the fd, but it’s still good to know IMHO).
 
 - Important: AFAICT the absolute ref for `PATH` resolution is [from exec function in FreeBSD source](https://opensource.apple.com/source/Libc/Libc-1439.100.3/gen/FreeBSD/exec.c.auto.html) (end of file).
 Sadly `Process` does not report the actual errors and seem to always report “File not found” errors when the executable cannot be run.
 So we do not fully emulate exec’s behavior. */
public struct ProcessInvocation : AsyncSequence {
	
	public typealias ProcessOutputHandler = (_ rawLineWithSource: RawLineWithSource, _ signalEndOfInterestForStream: () -> Void, _ process: Process) -> Void
	
	public typealias AsyncIterator = Iterator
	public typealias Element = RawLineWithSource
	
	public var executable: FilePath
	public var args: [String] = []
	
	/**
	 Try and search the executable in the `PATH` environment variable when the executable path is a simple word (shell-like search).
	 
	 If `false` (default) the standard `Process` behavior will apply: resolve the executable path just like any other path and execute that.
	 If not using `PATH` and there are fds to send, the `XCT_EXEC_PATH` env var becomes mandatory.
	 We have to know the location of the `xct` executable.
	 If using `PATH` with fds to send, the xct executable is searched normally, except the `XCT_EXEC_PATH` path is tried first, if defined.
	 The environment is never modified (neither for the executed process nor the current one), regardless of this variable or whether there are additional fds to send.
	 The `PATH` is modified for the `xct` launcher when sending fds (and only for it) so that all paths are absolute though.
	 The subprocess will still see the original `PATH`.
	 
	 - Note: Setting ``usePATH`` to `false` or ``customPATH`` to an empty array is technically equivalent.
	 (But setting ``usePATH`` to `false` is marginally faster). */
	public var usePATH: Bool = true
	/**
	 Override the PATH environment variable and use this.
	 
	 Empty strings are the same as “`.`”.
	 This parameter allows having a “PATH” containing colons, which the standard `PATH` variable does not allow.
	 _However_ this does not work when there are fds to send, in which case the paths containing colons are **removed** (for security reasons).
	 Maybe one day we’ll enable it in this case too, but for now it’s not enabled.
	 
	 Another difference when there are fds to send regarding the PATH is all the paths are made absolute.
	 This avoids any problem when the ``workingDirectory`` parameter is set to a non-null value.
	 
	 Finally the parameter is a double-optional.
	 It can be set
	  to `.none`, which means the default `PATH` env variable will be used,
	  to `.some(.none)`, in which case the default `PATH` is used (`_PATH_DEFPATH`, see `exec(3)`) or
	  to a non-nil value, in which case this value is used. */
	public var customPATH: [FilePath]?? = nil
	
	public var workingDirectory: URL? = nil
	public var environment: [String: String]? = nil
	
	public var stdin: FileDescriptor? = nil
	public var stdoutRedirect: RedirectMode = .capture
	public var stderrRedirect: RedirectMode = .capture
	
	public var signalsToForward: Set<Signal> = Signal.toForwardToSubprocesses
	
	/**
	 The file descriptors (other than `stdin`, `stdout` and `stderr`, which are handled differently) to clone in the child process.
	 They are closed once the process has been launched.
	 
	 The **value** is the file descriptor to clone (from the parent process to the child),
	 the key is the descriptor you’ll get in the child process.
	 
	 - Important: The function takes ownership of these file descriptors, i.e. it closes them when the process has been launched.
	 You should dup your fds if you need to keep a ref to them. */
	public var fileDescriptorsToSend: [FileDescriptor /* Value in **child** */: FileDescriptor /* Value in **parent** */] = [:]
	/**
	 Additional output file descriptors to stream from the process.
	 
	 Usually used with ``fileDescriptorsToSend``
	 (you open a socket, give the write fd in fds to clone, and the read fd to additional output fds).
	 
	 - Important: The function takes ownership of these file descriptors, i.e. it closes them when the end of their respective streams is reached.
	 You should dup your fds if you need to keep a ref to them. */
	public var additionalOutputFileDescriptors: Set<FileDescriptor> = []
	
	/**
	 The line separator to expect in the process output.
	 Usually will be a simple newline character, but can also be the zero char (e.g. `find -print0`), or windows newlines, or something else.
	 
	 This property should probably not be part of a ``ProcessInvocation`` per se as
	 technically the process could be invoked whether this is known or not.
	 However,
	  because ``ProcessInvocation`` is an `AsyncSequence`,
	  and we cannot specify options when iterating on a sequence,
	 we have to know in advance the line separator to expect!
	 
	 One could probably argue
	  the `ProcessInvocation` sequence element should be of type `UInt8` and
	  we’d receive all the bytes one after the other, and
	  we’d wrap the ProcessInvocation in an `AsyncLineSequence` to get the lines of text.
	 
	 We have the following counterpoints:
	 1. The `AsyncLineSequence` cannot be customized (AFAICT), and we _have to_ trust it do to the right thing
	 (which will necessarily not be the right thing when processing the output of `find -print0` for instance).
	 This could be worked-around by creating a specific wrapping sequence, just like `AsyncLineSequence`, but customizable,
	 or by using another sequence wrapper for the `print0` option;
	 2. Sending the bytes one by one is probably (to be tested) slower than sending chunks of data directly;
	 3. We have a bit of history with this API, and we have a primitive to split the lines in a stream already.
	 
	 So, for simplicity, we leave it that way, at least for now. */
	public var lineSeparators: LineSeparators = .default
	/**
	 A global handler called after each new lines of text to check if the client is still interested in the stream.
	 If it is not, the stream will be closed.
	 
	 The handler is set at process invocation time:
	 when the process is invoked, if this property is modified, the original handler will still be called. */
	public var shouldContinueStreamHandler: ((_ line: RawLineWithSource, _ process: Process) -> Bool)?
	
	/**
	 The terminations to expect from the process.
	 
	 Much like ``lineSeparators``
	  this property should probably not be a part of ``ProcessInvocation``,
	  but like ``lineSeparators``, because ``ProcessInvocation`` is an AsyncSequence
	 we have to know in advance the expected terminations of the process
	  in order to be able to correctly throw when process is over if termination is unexpected. */
	public var expectedTerminations: [(Int32, Process.TerminationReason)]?
	
	public init(
		_ executable: FilePath, _ args: String..., usePATH: Bool = true, customPATH: [FilePath]?? = nil,
		workingDirectory: URL? = nil, environment: [String: String]? = nil,
		stdin: FileDescriptor? = nil, stdoutRedirect: RedirectMode = .capture, stderrRedirect: RedirectMode = .capture,
		signalsToForward: Set<Signal> = Signal.toForwardToSubprocesses,
		fileDescriptorsToSend: [FileDescriptor /* Value in **child** */: FileDescriptor /* Value in **parent** */] = [:],
		additionalOutputFileDescriptors: Set<FileDescriptor> = [],
		lineSeparators: LineSeparators = .default,
		shouldContinueStreamHandler: ((_ line: RawLineWithSource, _ process: Process) -> Bool)? = nil,
		expectedTerminations: [(Int32, Process.TerminationReason)]?? = nil
	) {
		self.init(
			executable, args: args, usePATH: usePATH, customPATH: customPATH,
			workingDirectory: workingDirectory, environment: environment,
			stdin: stdin, stdoutRedirect: stdoutRedirect, stderrRedirect: stderrRedirect,
			signalsToForward: signalsToForward,
			fileDescriptorsToSend: fileDescriptorsToSend,
			additionalOutputFileDescriptors: additionalOutputFileDescriptors,
			lineSeparators: lineSeparators,
			shouldContinueStreamHandler: shouldContinueStreamHandler,
			expectedTerminations: expectedTerminations
		)
	}
	
	/**
	 Init a process invocation.
	 
	 - Parameter expectedTerminations: A double-optional to define the expected terminations.
	 If left at default (set to `nil`), the expected termination will be
	  a standard exit with exit code 0 if there are no ``shouldContinueStreamHandler`` defined, and
	  a standard exit with exit code 0 + broken pipe exception exit otherwise.
	 If set to `.some(.none)`, the expected termination will be set to nil, in which case any termination pass the termination check.
	 If set to a non-optional value, the expected terminations will be set to this value. */
	public init(
		_ executable: FilePath, args: [String], usePATH: Bool = true, customPATH: [FilePath]?? = nil,
		workingDirectory: URL? = nil, environment: [String: String]? = nil,
		stdin: FileDescriptor? = nil, stdoutRedirect: RedirectMode = .capture, stderrRedirect: RedirectMode = .capture,
		signalsToForward: Set<Signal> = Signal.toForwardToSubprocesses,
		fileDescriptorsToSend: [FileDescriptor /* Value in **child** */: FileDescriptor /* Value in **parent** */] = [:],
		additionalOutputFileDescriptors: Set<FileDescriptor> = [],
		lineSeparators: LineSeparators = .default,
		shouldContinueStreamHandler: ((_ line: RawLineWithSource, _ process: Process) -> Bool)? = nil,
		expectedTerminations: [(Int32, Process.TerminationReason)]?? = nil
	) {
		self.executable = executable
		self.args = args
		self.usePATH = usePATH
		self.customPATH = customPATH
		
		self.workingDirectory = workingDirectory
		self.environment = environment
		
		self.stdin = stdin
		self.stdoutRedirect = stdoutRedirect
		self.stderrRedirect = stderrRedirect
		
		self.signalsToForward = signalsToForward
		
		self.fileDescriptorsToSend = fileDescriptorsToSend
		self.additionalOutputFileDescriptors = additionalOutputFileDescriptors
		
		self.lineSeparators = lineSeparators
		
		self.shouldContinueStreamHandler = shouldContinueStreamHandler
		switch expectedTerminations {
			case .none:               self.expectedTerminations = (shouldContinueStreamHandler == nil ? [(0, .exit)] : [(0, .exit), (Signal.brokenPipe.rawValue, .uncaughtSignal)])
			case .some(.none):        self.expectedTerminations = nil
			case .some(.some(let v)): self.expectedTerminations = v
		}
	}
	
	public func makeAsyncIterator() -> Iterator {
		return Iterator(invocation: self)
	}
	
	/**
	 Invoke the process, then returns stdout lines.
	 
	 When using this method, the end of lines are lost.
	 Each line is stripped of the end of line separator.
	 Usually not a big deal; basically it means you won’t know if the last line had the end of line separator or not.
	 If you need this information, use ``invokeAndGetOutput(encoding:)``. */
	public func invokeAndGetStdout(encoding: String.Encoding = .utf8) async throws -> [String] {
		return try await invokeAndGetStdout(checkValidTerminations: true, encoding: encoding).0
	}
	
	public func invokeAndGetOutput(encoding: String.Encoding = .utf8) async throws -> [LineWithSource] {
		return try await invokeAndGetOutput(checkValidTerminations: true, encoding: encoding).0
	}
	
	public func invokeAndGetRawOutput() async throws -> [RawLineWithSource] {
		return try await invokeAndGetRawOutput(checkValidTerminations: true).0
	}
	
	public func invokeAndStreamOutput(outputHandler: @escaping ProcessInvocation.ProcessOutputHandler) async throws {
		_ = try await invokeAndStreamOutput(checkValidTerminations: true, outputHandler: outputHandler)
	}
	
	public func invokeAndGetStdout(checkValidTerminations: Bool, encoding: String.Encoding = .utf8) async throws -> ([String], Int32, Process.TerminationReason) {
		let (output, exitStatus, exitReason) = try await invokeAndGetOutput(checkValidTerminations: checkValidTerminations, encoding: encoding)
		return (output.compactMap{ $0.fd == .standardOutput ? $0.line : nil }, exitStatus, exitReason)
	}
	
	public func invokeAndGetOutput(checkValidTerminations: Bool, encoding: String.Encoding = .utf8) async throws -> ([LineWithSource], Int32, Process.TerminationReason) {
		let (rawOutput, exitStatus, exitReason) = try await invokeAndGetRawOutput(checkValidTerminations: checkValidTerminations)
		return try (rawOutput.map{ try $0.strLineWithSource(encoding: encoding) }, exitStatus, exitReason)
	}
	
	/**
	 Launch the invocation and returns the output of the process.
	 If there are any I/O issues while reading the output file descriptors from the Process,
	  the whole invocation is considered failed and an error is thrown. */
	public func invokeAndGetRawOutput(checkValidTerminations: Bool) async throws -> ([RawLineWithSource], Int32, Process.TerminationReason) {
		var lines = [RawLineWithSource]()
		let (exitStatus, exitReason) = try await invokeAndStreamOutput(checkValidTerminations: checkValidTerminations, outputHandler: { line, _, _ in
			lines.append(line)
		})
		return (lines, exitStatus, exitReason)
	}
	
	/**
	 Launch the invocation and streams the output in the given handler.
	 If there is at least one error reading from _any_ of the input stream at any given time,
	  the whole function will throw an ``XcodeToolsError/outputReadError(_:)`` error,
	  and any new lines that might be received on other streams are not sent to the handler anymore.
	 The process is not stopped though, and it is waited on normally.
	 
	 - Parameter outputHandler: This handler is called after a new line is caught from any of the output file descriptors.
	 You get
	  the line and the separator as `Data`,
	  the source fd that generated this data (if `stdout` or `stderr` were set to `.capture`, you’ll get resp. the `stdout`/`stderr` fds even though the data is not technically coming from these)
	  and the source process.
	 You are also given a handler you can call to notify the end of interest in the stream (which closes the corresponding fd).
	 __Important__: Do **not** close the fd yourself.
	 Do not do any action on the fd actually.
	 Especially, do not read from it. */
	public func invokeAndStreamOutput(checkValidTerminations: Bool, outputHandler: @escaping ProcessInvocation.ProcessOutputHandler) async throws -> (Int32, Process.TerminationReason) {
		/* We want this variable to be immutable once the process is launched. */
		let expectedTerminations = expectedTerminations
		
		/* 1. First launch the process. */
		var outputError: Error?
		let (p, g) = try invoke{ result, signalEndOfInterestForStream, process in
			guard outputError == nil else {
				/* We do not signal end of interest in stream when we have an output error to avoid forcing a broken pipe error,
				 * _but_ we stop reading from any stream as soon as we get at least one error. */
				return
			}
			switch result {
				case .success(let line): outputHandler(line, signalEndOfInterestForStream, process)
				case .failure(let error): outputError = error
			}
		}
		/* 2. Then wait for it to quit and all the stream to be read fully. */
		await withCheckedContinuation{ continuation in
			g.notify(queue: ProcessInvocation.streamQueue, execute: {
				continuation.resume()
			})
		}
		/* 3. If there was an error reading the process output, we throw. */
		try outputError?.throw{ Err.outputReadError($0) }
		/* 4. Retreive process termination status+reason and check them if needed. */
		let (exitStatus, exitReason) = (p.terminationStatus, p.terminationReason)
		if checkValidTerminations {
			try Self.checkTermination(expectedTerminations: expectedTerminations, terminationStatus: exitStatus, terminationReason: exitReason)
		}
		/* 5. We’re done, everything went well! */
		return (exitStatus, exitReason)
	}
	
	/**
	 Invoke the process but does not wait on it.
	 
	 You retrieve the process and a dispatch group you can wait on to be notified when the process and all of its outputs are done.
	 You can also set the termination handler of the process, but you should wait on the dispatch group to be sure all of the outputs have finished streaming. */
	public func invoke(outputHandler: @escaping (_ result: Result<RawLineWithSource, Error>, _ signalEndOfInterestForStream: () -> Void, _ process: Process) -> Void, terminationHandler: ((_ process: Process) -> Void)? = nil) throws -> (Process, DispatchGroup) {
		assert(!fileDescriptorsToSend.values.contains(.standardOutput), "Standard output must be modified using stdoutRedirect")
		assert(!fileDescriptorsToSend.values.contains(.standardError), "Standard error must be modified using stderrRedirect")
		
		let g = DispatchGroup()
#if canImport(eXtenderZ)
		let p = Process()
#else
		let p = XcodeToolsProcess()
#endif
		
		let actualOutputHandler: (_ result: Result<RawLineWithSource, Error>, _ signalEndOfInterestForStream: () -> Void, _ process: Process) -> Void
		if let shouldContinueStreamHandler = shouldContinueStreamHandler {
			actualOutputHandler = { result, signalEndOfInterestForStream, process in
				outputHandler(result, signalEndOfInterestForStream, process)
				if case .success(let line) = result, !shouldContinueStreamHandler(line, process) {
					signalEndOfInterestForStream()
				}
			}
		} else {
			actualOutputHandler = outputHandler
		}
		
		p.terminationHandler = terminationHandler
		if let environment      = environment      {p.environment         = environment}
		if let workingDirectory = workingDirectory {p.currentDirectoryURL = workingDirectory}
		
		var fdsToCloseInCaseOfError = Set<FileDescriptor>()
		var fdToSwitchToBlockingInCaseOfError = Set<FileDescriptor>()
		var countOfDispatchGroupLeaveInCaseOfError = 0
		var signalCleaningOnError: (() -> Void)?
		func cleanupAndThrow(_ error: Error) throws -> Never {
			signalCleaningOnError?()
			for _ in 0..<countOfDispatchGroupLeaveInCaseOfError {g.leave()}
			
			/* Only the fds that are not ours, and thus not in additional output fds are allowed to be closed in case of error. */
			assert(additionalOutputFileDescriptors.intersection(fdsToCloseInCaseOfError).isEmpty)
			/* We only try and revert fds to blocking for fds we don’t own.
			 * Only those in additional output fds. */
			assert(additionalOutputFileDescriptors.isSuperset(of: fdToSwitchToBlockingInCaseOfError))
			/* The assert below is a consequence of the two above. */
			assert(fdsToCloseInCaseOfError.intersection(fdToSwitchToBlockingInCaseOfError).isEmpty)
			
			fdToSwitchToBlockingInCaseOfError.forEach{ fd in
				do    {try Self.removeRequireNonBlockingIO(on: fd)}
				catch {Conf.logger?.error("Cannot revert fd \(fd.rawValue) to blocking.")}
			}
			fdsToCloseInCaseOfError.forEach{ try? $0.close() }
			
			throw error
		}
		func cleanupIfThrows<R>(_ block: () throws -> R) rethrows -> R {
			do {return try block()}
			catch {
				try cleanupAndThrow(error)
			}
		}
		
		var fdsToCloseAfterRun = Set<FileDescriptor>()
		var fdRedirects = [FileDescriptor: FileDescriptor]()
		var outputFileDescriptors = additionalOutputFileDescriptors
		switch stdoutRedirect {
			case .none: (/*nop*/)
			case .toNull: p.standardOutput = nil
			case .toFd(let fd, let shouldClose):
				p.standardOutput = FileHandle(fileDescriptor: fd.rawValue, closeOnDealloc: false)
				if shouldClose {fdsToCloseAfterRun.insert(fd)}
				
			case .capture:
				/* We use an unowned pipe because we want absolute control on when either side of the pipe is closed. */
				let (fdForReading, fdForWriting) = try Self.unownedPipe()
				
				let (inserted, _) = outputFileDescriptors.insert(fdForReading); assert(inserted)
				fdRedirects[fdForReading] = FileDescriptor.standardOutput
				
				fdsToCloseAfterRun.insert(fdForWriting)
				fdsToCloseInCaseOfError.insert(fdForReading)
				fdsToCloseInCaseOfError.insert(fdForWriting)
				
				Conf.logger?.trace("stdout pipe is r:\(fdForReading.rawValue) w:\(fdForWriting.rawValue)")
				p.standardOutput = FileHandle(fileDescriptor: fdForWriting.rawValue, closeOnDealloc: false)
		}
		switch stderrRedirect {
			case .none: (/*nop*/)
			case .toNull: p.standardError = nil
			case .toFd(let fd, let shouldClose):
				p.standardError = FileHandle(fileDescriptor: fd.rawValue, closeOnDealloc: false)
				if shouldClose {fdsToCloseAfterRun.insert(fd)}
				
			case .capture:
				let (fdForReading, fdForWriting) = try Self.unownedPipe()
				
				let (inserted, _) = outputFileDescriptors.insert(fdForReading); assert(inserted)
				fdRedirects[fdForReading] = FileDescriptor.standardError
				
				fdsToCloseAfterRun.insert(fdForWriting)
				fdsToCloseInCaseOfError.insert(fdForReading)
				fdsToCloseInCaseOfError.insert(fdForWriting)
				
				Conf.logger?.trace("stderr pipe is r:\(fdForReading.rawValue) w:\(fdForWriting.rawValue)")
				p.standardError = FileHandle(fileDescriptor: fdForWriting.rawValue, closeOnDealloc: false)
		}
		
#if os(Linux)
		/* I did not find any other way than using non-blocking IO on Linux.
		 * <https://stackoverflow.com/questions/39173429/one-shot-level-triggered-epoll-does-epolloneshot-imply-epollet/46142976#comment121697690_46142976> */
		for fd in outputFileDescriptors {
			try cleanupIfThrows{
				let isFromClient = additionalOutputFileDescriptors.contains(fd)
				try Self.setRequireNonBlockingIO(on: fd, logChange: isFromClient)
				if isFromClient {
					/* The fd is not ours.
					 * We must try and revert it to its original state if the function throws an error. */
					assert(!fdsToCloseInCaseOfError.contains(fd))
					fdToSwitchToBlockingInCaseOfError.insert(fd)
				}
			}
		}
#endif
		
		let fdToSendFds: FileDescriptor?
		/* We will modify it later to add stdin if needed. */
		var fileDescriptorsToSend = fileDescriptorsToSend
		
		/* Let’s compute the PATH. */
		/** The resolved PATH */
		let PATH: [FilePath]
		/** `true` if the default `_PATH_DEFPATH` path is used.
		 The variable is used when using the `xct` launcher. */
		let isDefaultPATH: Bool
		/** Set if we use the `xct` launcher. */
		let forcedPreprendedPATH: FilePath?
		if usePATH {
			if case .some(.some(let p)) = customPATH {
				PATH = p
				isDefaultPATH = false
			} else {
				let PATHstr: String
				if case .some(.none) = customPATH {
					/* We use the default path: _PATH_DEFPATH */
					PATHstr = _PATH_DEFPATH
					isDefaultPATH = true
				} else {
					/* We use the PATH env var */
					let envPATHstr = getenv("PATH").flatMap{ String(cString: $0) }
					PATHstr = envPATHstr ?? _PATH_DEFPATH
					isDefaultPATH = (envPATHstr == nil)
				}
				PATH = PATHstr.split(separator: ":", omittingEmptySubsequences: false).map{ FilePath(String($0)) }
			}
		} else {
			PATH = []
			isDefaultPATH = false
		}
		
		let actualExecutablePath: FilePath
		if fileDescriptorsToSend.isEmpty {
			/* We add closeOnDealloc:false to be explicit, but it’s the default. */
			p.standardInput = stdin.flatMap{ FileHandle(fileDescriptor: $0.rawValue, closeOnDealloc: false) }
			p.arguments = args
			actualExecutablePath = executable
			forcedPreprendedPATH = nil
			fdToSendFds = nil
		} else {
			let execBasePath = getenv(XcodeToolsConstants.envVarNameExecPath).flatMap{ FilePath(String(cString: $0)) }
			if !usePATH {
				guard let execBasePath = execBasePath else {
					XcodeToolsConfig.logger?.error("Cannot launch process and send its fd if \(XcodeToolsConstants.envVarNameExecPath) is not set.")
					try cleanupAndThrow(XcodeToolsError.envVarXctExecPathNotSet)
				}
				actualExecutablePath = execBasePath.appending("xct")
				forcedPreprendedPATH = nil
			} else {
				actualExecutablePath = "xct"
				forcedPreprendedPATH = execBasePath
			}
			
			/* The socket to send the fd.
			 * The tuple thingy _should_ be _in effect_ equivalent to the C version `int sv[2] = {-1, -1};`.
			 * <https://forums.swift.org/t/guarantee-in-memory-tuple-layout-or-dont/40122>
			 * Stride and alignment should be the equal for CInt.
			 * Funnily, it seems to only work in debug compilation, not in release…
			 * var sv: (CInt, CInt) = (-1, -1) */
			let sv = UnsafeMutablePointer<CInt>.allocate(capacity: 2)
			sv.initialize(repeating: -1, count: 2)
			defer {sv.deallocate()}
#if !os(Linux)
			let sockDgram = SOCK_DGRAM
#else
			let sockDgram = Int32(SOCK_DGRAM.rawValue)
#endif
			guard socketpair(/*domain: */AF_UNIX, /*type: */sockDgram, /*protocol: */0, /*socket_vector: */sv) == 0 else {
				/* TODO: Throw a more informative error? */
				try cleanupAndThrow(XcodeToolsError.systemError(Errno(rawValue: errno)))
			}
			let fd0 = FileDescriptor(rawValue: sv.advanced(by: 0).pointee)
			let fd1 = FileDescriptor(rawValue: sv.advanced(by: 1).pointee)
			assert(fd0.rawValue != -1 && fd1.rawValue != -1)
			
			fdsToCloseAfterRun.insert(fd1)
			fdsToCloseInCaseOfError.insert(fd0)
			fdsToCloseInCaseOfError.insert(fd1)
			
			let cwd = FilePath(FileManager.default.currentDirectoryPath)
			if !cwd.isAbsolute {XcodeToolsConfig.logger?.error("currentDirectoryPath is not abolute! Madness may ensue.", metadata: ["path": "\(cwd)"])}
			/* We make all paths absolute, and filter the ones containing colons. */
			let PATHstr = (!isDefaultPATH ? PATH.map{ cwd.pushing($0).string }.filter{ $0.firstIndex(of: ":") == nil }.joined(separator: ":") : nil)
			let PATHoption = PATHstr.flatMap{ ["--path", $0] } ?? []
			
			p.arguments = ["internal-fd-get-launcher", usePATH ? "--use-path" : "--no-use-path"] + PATHoption + [executable.string] + args
			p.standardInput = FileHandle(fileDescriptor: fd1.rawValue, closeOnDealloc: false)
			fdToSendFds = fd0
			
			if fileDescriptorsToSend[FileDescriptor.standardInput] == nil {
				/* We must add stdin in the list of file descriptors to send so that
				 * stdin is restored to its original value when the final process is exec’d from xct. */
				fileDescriptorsToSend[FileDescriptor.standardInput] = FileDescriptor.standardInput
			}
		}
		
		let delayedSigations = try cleanupIfThrows{ try SigactionDelayer_Unsig.registerDelayedSigactions(signalsToForward, handler: { (signal, handler) in
			XcodeToolsConfig.logger?.debug("Handler action in Process+Utils", metadata: ["signal": "\(signal)"])
			defer {handler(true)}
			
			guard p.isRunning else {return}
			kill(p.processIdentifier, signal.rawValue)
		}) }
		let signalCleanupHandler = {
			let errors = SigactionDelayer_Unsig.unregisterDelayedSigactions(Set(delayedSigations.values))
			for (signal, error) in errors {
				XcodeToolsConfig.logger?.error("Cannot unregister delayed sigaction: \(error)", metadata: ["signal": "\(signal)"])
			}
		}
		signalCleaningOnError = signalCleanupHandler
		
		let additionalTerminationHandler: (Process) -> Void = { _ in
			XcodeToolsConfig.logger?.debug("Called in termination handler of process")
			signalCleanupHandler()
			g.leave()
		}
#if canImport(eXtenderZ)
		HPNCheckedAddExtender(p, XcodeToolsProcessExtender(additionalTerminationHandler))
#else
		p.privateTerminationHandler = additionalTerminationHandler
#endif
		
		/* We used to enter the dispatch group in the registration handlers of the dispatch sources,
		 * but we got races where the executable ended before the distatch sources were even registered.
		 * So now we enter the group before launching the executable.
		 * We enter also once for the process launch (left in additional termination handler of the process). */
		countOfDispatchGroupLeaveInCaseOfError = outputFileDescriptors.count + 1
		for _ in 0..<countOfDispatchGroupLeaveInCaseOfError {
			g.enter()
		}
		
		XcodeToolsConfig.logger?.info("Launching process \(executable)\(fileDescriptorsToSend.isEmpty ? "" : " through xct")")
		try cleanupIfThrows{
			let actualPATH = [forcedPreprendedPATH].compactMap{ $0 } + PATH
			func tryPaths(from index: Int, executableComponent: FilePath.Component) throws {
				do {
					let url = URL(fileURLWithPath: actualPATH[index].appending([executableComponent]).string)
					XcodeToolsConfig.logger?.debug("Trying path \(url.path)")
					p.executableURL = url
					try p.run()
				} catch {
					let nserror = error as NSError
					switch (nserror.domain, nserror.code) {
						case (NSCocoaErrorDomain, NSFileNoSuchFileError) /* Apple platforms */,
							  (NSCocoaErrorDomain, CocoaError.Code.fileReadNoSuchFile.rawValue) /* Linux */:
							let nextIndex = actualPATH.index(after: index)
							if nextIndex < actualPATH.endIndex {
								try tryPaths(from: nextIndex, executableComponent: executableComponent)
							} else {
								throw error
							}
							
						default:
							throw error
					}
				}
			}
			if usePATH, !actualPATH.isEmpty, !actualExecutablePath.isAbsolute, actualExecutablePath.components.count == 1, let component = actualExecutablePath.components.last {
				try tryPaths(from: actualPATH.startIndex, executableComponent: component)
			} else {
				p.executableURL = URL(fileURLWithPath: actualExecutablePath.string)
				try p.run()
			}
			/* Decrease count of group leaves needed because now that the process is launched, its termination handler will be called. */
			countOfDispatchGroupLeaveInCaseOfError -= 1
			signalCleaningOnError = nil
			try fdsToCloseAfterRun.forEach{
				try $0.close()
				fdsToCloseInCaseOfError.remove($0)
			}
			if !fileDescriptorsToSend.isEmpty {
				let fdToSendFds = fdToSendFds!
				try withUnsafeBytes(of: Int32(fileDescriptorsToSend.count), { bytes in
					guard try fdToSendFds.write(bytes) == bytes.count else {
						throw Err.internalError("Unexpected count of sent bytes to fdToSendFds")
					}
				})
				for (fdInChild, fdToSend) in fileDescriptorsToSend {
					try Self.send(fd: fdToSend.rawValue, destfd: fdInChild.rawValue, to: fdToSendFds.rawValue)
				}
				XcodeToolsConfig.logger?.trace("Closing fd to send fds")
				try fdToSendFds.close()
				XcodeToolsConfig.logger?.trace("Closing sent fds")
				try fileDescriptorsToSend.values.forEach{ if $0 != .standardInput {try $0.close()} }
				fdsToCloseInCaseOfError.remove(fdToSendFds) /* Not really useful there cannot be any more errors from there. */
			}
		}
		
		for fd in outputFileDescriptors {
			let streamReader = FileDescriptorReader(stream: fd, bufferSize: 1024, bufferSizeIncrement: 512)
			streamReader.underlyingStreamReadSizeLimit = 0
			
			let streamSource = DispatchSource.makeReadSource(fileDescriptor: fd.rawValue, queue: Self.streamQueue)
			streamSource.setCancelHandler{
				_ = try? fd.close()
				g.leave()
			}
			streamSource.setEventHandler{
				/* `source.data`: see doc of dispatch_source_get_data in objc */
				/* `source.mask`: see doc of dispatch_source_get_mask in objc (is always 0 for read source) */
				Self.handleProcessOutput(
					streamSource: streamSource,
					streamQueue: Self.streamQueue,
					outputHandler: { lineOrError, signalEOI in actualOutputHandler(lineOrError.map{ RawLineWithSource(line: $0.0, eol: $0.1, fd: fdRedirects[fd] ?? fd) }, signalEOI, p) },
					lineSeparators: lineSeparators,
					streamReader: streamReader,
					estimatedBytesAvailable: streamSource.data
				)
			}
			streamSource.activate()
		}
		
		return (p, g)
	}
	
	/**
	 Returns a simple pipe. Different than using the `Pipe()` object from Foundation because you get control on when the fds are closed.
	 
	 - Important: The `FileDescriptor`s returned **must** be closed manually. */
	public static func unownedPipe() throws -> (fdRead: FileDescriptor, fdWrite: FileDescriptor) {
		let pipepointer = UnsafeMutablePointer<CInt>.allocate(capacity: 2)
		defer {pipepointer.deallocate()}
		pipepointer.initialize(to: -1)
		
		guard pipe(pipepointer) == 0 else {
			throw Err.systemError(Errno(rawValue: errno))
		}
		
		let fdRead  = pipepointer.advanced(by: 0).pointee
		let fdWrite = pipepointer.advanced(by: 1).pointee
		assert(fdRead != -1 && fdWrite != -1)
		
		return (FileDescriptor(rawValue: fdRead), FileDescriptor(rawValue: fdWrite))
	}
	
	public struct Iterator : AsyncIteratorProtocol {
		
		public typealias Element = RawLineWithSource
		
		public mutating func next() async throws -> RawLineWithSource? {
			if outputIterator == nil {
				let outputSequence = AsyncThrowingStream<RawLineWithSource, Error>{ continuation in
					do {
						let (p, g) = try invocation.invoke{ result, _, _ in
							continuation.yield(with: result)
						}
						process = p
						g.notify(queue: ProcessInvocation.streamQueue, execute: {
							continuation.finish(throwing: nil)
						})
					} catch {
						continuation.finish(throwing: error)
					}
				}
				outputIterator = outputSequence.makeAsyncIterator()
			}
			if let n = try await outputIterator!.next() {
				return n
			} else {
				/* If there are no more elements, the process has ended. */
				let p = process!
				try ProcessInvocation.checkTermination(
					expectedTerminations: invocation.expectedTerminations,
					terminationStatus: p.terminationStatus, terminationReason: p.terminationReason
				)
				return nil
			}
		}
		
		internal init(invocation: ProcessInvocation) {
			self.invocation = invocation
		}
		
		private var process: Process?
		
		private let invocation: ProcessInvocation
		private var outputIterator: AsyncThrowingStream<RawLineWithSource, Error>.Iterator?
		
	}
	
	private static let streamQueue = DispatchQueue(label: "com.xcode-actions.process")
	
	private static func checkTermination(expectedTerminations: [(Int32, Process.TerminationReason)]?, terminationStatus: Int32, terminationReason: Process.TerminationReason) throws {
		guard let expectedTerminations = expectedTerminations else {
			return
		}
		guard expectedTerminations.contains(where: { $0.0 == terminationStatus && $0.1 == terminationReason }) else {
			throw Err.unexpectedSubprocessExit(terminationStatus: terminationStatus, terminationReason: terminationReason)
		}
	}
	
	private static func setRequireNonBlockingIO(on fd: FileDescriptor, logChange: Bool) throws {
		let curFlags = fcntl(fd.rawValue, F_GETFL)
		guard curFlags != -1 else {
			throw XcodeToolsError.systemError(Errno(rawValue: errno))
		}
		
		let newFlags = curFlags | O_NONBLOCK
		guard newFlags != curFlags else {
			/* Nothing to do */
			return
		}
		
		if logChange {
			/* We only log for fd that were not ours */
			XcodeToolsConfig.logger?.warning("Setting O_NONBLOCK option on fd \(fd)")
		}
		guard fcntl(fd.rawValue, F_SETFL, newFlags) != -1 else {
			throw XcodeToolsError.systemError(Errno(rawValue: errno))
		}
	}
	
	private static func removeRequireNonBlockingIO(on fd: FileDescriptor) throws {
		let curFlags = fcntl(fd.rawValue, F_GETFL)
		guard curFlags != -1 else {
			throw XcodeToolsError.systemError(Errno(rawValue: errno))
		}
		
		let newFlags = curFlags & ~O_NONBLOCK
		guard newFlags != curFlags else {
			/* Nothing to do */
			return
		}
		
		guard fcntl(fd.rawValue, F_SETFL, newFlags) != -1 else {
			throw XcodeToolsError.systemError(Errno(rawValue: errno))
		}
	}
	
	private static func handleProcessOutput(streamSource: DispatchSourceRead, streamQueue: DispatchQueue, outputHandler: @escaping (Result<(Data, Data), Error>, () -> Void) -> Void, lineSeparators: LineSeparators, streamReader: GenericStreamReader, estimatedBytesAvailable: UInt) {
		do {
			let toRead = Int(Swift.min(Swift.max(estimatedBytesAvailable, 1), UInt(Int.max)))
#if !os(Linux)
			/* We do not need to check the number of bytes actually read.
			 * If EOF was reached (nothing was read),
			 *  the stream reader will remember it, and
			 *  the readLine method will properly return nil without even trying to read from the stream.
			 * Which matters, because we forbid the reader from reading from the underlying stream (except in these read). */
			XcodeToolsConfig.logger?.trace("Reading around \(toRead) bytes from \(streamReader.sourceStream)")
			_ = try streamReader.readStreamInBuffer(size: toRead, allowMoreThanOneRead: false, bypassUnderlyingStreamReadSizeLimit: true)
#else
			XcodeToolsConfig.logger?.trace("In libdispatch callback for \(streamReader.sourceStream)")
			/* On Linux we have to use non-blocking IO for some reason.
			 * I’d say it’s a libdispatch bug, but I’m not sure.
			 * <https://stackoverflow.com/questions/39173429#comment121697690_46142976> */
			let read: () throws -> Int = {
				XcodeToolsConfig.logger?.trace("Reading around \(toRead) bytes from \(streamReader.sourceStream)")
				return try streamReader.readStreamInBuffer(size: toRead, allowMoreThanOneRead: false, bypassUnderlyingStreamReadSizeLimit: true)
			}
			let processError: (Error) -> Result<Int, Error> = { e in
				if case Errno.resourceTemporarilyUnavailable = e {
					XcodeToolsConfig.logger?.trace("Masking resource temporarily unavailable error")
					return .success(0)
				}
				return .failure(e)
			}
			while try Result(catching: read).flatMapError(processError).get() >= toRead {/*nop*/}
#endif
			
			let readLine: () throws -> (Data, Data)?
			switch lineSeparators {
				case .newLine(let unix, let legacyMacOS, let windows):
					readLine = {
						try streamReader.readLine(allowUnixNewLines: unix, allowLegacyMacOSNewLines: legacyMacOS, allowWindowsNewLines: windows)
					}
					
				case .customCharacters(let set):
					readLine = {
						let ret = try streamReader.readData(upTo: set.map{ Data([$0]) }, matchingMode: .shortestDataWins, failIfNotFound: false, includeDelimiter: false)
						_ = try streamReader.readData(size: ret.delimiter.count, allowReadingLess: false)
						guard !ret.data.isEmpty || !ret.delimiter.isEmpty else {
							return nil
						}
						return ret
					}
			}
			while let (lineData, eolData) = try readLine() {
				var continueStream = true
				outputHandler(.success((lineData, eolData)), { continueStream = false })
				guard continueStream else {
					XcodeToolsConfig.logger?.debug("Client is not interested in stream anymore; cancelling read stream for \(streamReader.sourceStream)")
					streamSource.cancel()
					return
				}
			}
			/* We have read all the stream, we can stop */
			XcodeToolsConfig.logger?.debug("End of stream reached; cancelling read stream for \(streamReader.sourceStream)")
			streamSource.cancel()
			
		} catch StreamReaderError.streamReadForbidden {
			XcodeToolsConfig.logger?.trace("Error reading from \(streamReader.sourceStream): stream read forbidden (this is normal)")
			
		} catch {
			XcodeToolsConfig.logger?.warning("Error reading from \(streamReader.sourceStream): \(error)")
			outputHandler(.failure(error), { })
			/* We stop the stream at first unknown error. */
			streamSource.cancel()
		}
	}
	
	/* Based on <https://stackoverflow.com/a/28005250> (last variant). */
	private static func send(fd: CInt, destfd: CInt, to socket: CInt) throws {
		var fd = fd /* A var because we use a pointer to it at some point, but never actually modified */
		let sizeOfFd = MemoryLayout.size(ofValue: fd) /* We’ll need this later */
		let sizeOfDestfd = MemoryLayout.size(ofValue: destfd) /* We’ll need this later */
		
		var msg = msghdr()
		
		/* We’ll place the destination fd (a simple CInt) in an iovec. */
		let iovBase = UnsafeMutablePointer<CInt>.allocate(capacity: 1)
		defer {iovBase.deallocate()}
		iovBase.initialize(to: destfd)
		
		let ioPtr = UnsafeMutablePointer<iovec>.allocate(capacity: 1)
		defer {ioPtr.deallocate()}
		ioPtr.initialize(to: iovec(iov_base: iovBase, iov_len: sizeOfDestfd))
		
		msg.msg_iov = ioPtr
		msg.msg_iovlen = 1
		
		/* Ancillary data. This is where we send the actual fd. */
		let buf = UnsafeMutableRawPointer.allocate(byteCount: XCT_CMSG_SPACE(sizeOfFd), alignment: MemoryLayout<cmsghdr>.alignment)
		defer {buf.deallocate()}
		
#if !os(Linux)
		msg.msg_control = UnsafeMutableRawPointer(buf)
		msg.msg_controllen = socklen_t(XCT_CMSG_SPACE(sizeOfFd))
#else
		msg.msg_control = UnsafeMutableRawPointer(buf)
		msg.msg_controllen = Int(XCT_CMSG_SPACE(sizeOfFd))
#endif
		
		guard let cmsg = XCT_CMSG_FIRSTHDR(&msg) else {
			throw XcodeToolsError.internalError("CMSG_FIRSTHDR returned nil.")
		}
		
#if !os(Linux)
		cmsg.pointee.cmsg_type = SCM_RIGHTS
		cmsg.pointee.cmsg_level = SOL_SOCKET
#else
		cmsg.pointee.cmsg_type = Int32(SCM_RIGHTS)
		cmsg.pointee.cmsg_level = SOL_SOCKET
#endif
		
#if !os(Linux)
		cmsg.pointee.cmsg_len = socklen_t(XCT_CMSG_LEN(sizeOfFd))
#else
		cmsg.pointee.cmsg_len = Int(XCT_CMSG_LEN(sizeOfFd))
#endif
		memmove(XCT_CMSG_DATA(cmsg), &fd, sizeOfFd)
		
		guard sendmsg(socket, &msg, /*flags: */0) != -1 else {
			throw XcodeToolsError.systemError(Errno(rawValue: errno))
		}
		XcodeToolsConfig.logger?.debug("sent fd \(fd) through socket to child process")
	}
	
}



#if canImport(eXtenderZ)

class XcodeToolsProcessExtender : NSObject, XCTTaskExtender {
	
	let additionalCompletionHandler: (Process) -> Void
	
	init(_ completionHandler: @escaping (Process) -> Void) {
		self.additionalCompletionHandler = completionHandler
	}
	
	func prepareObject(forExtender object: NSObject) -> Bool {return true}
	func prepareObjectForRemoval(ofExtender object: NSObject) {/*nop*/}
	
}

#else

/**
 A subclass of Process whose termination handler is overridden, in order for XcodeTools
  to set its own termination handler and
  still let clients use it. */
private class XcodeToolsProcess : Process {
	
	var privateTerminationHandler: ((Process) -> Void)? {
		didSet {updateTerminationHandler()}
	}
	
	override init() {
		super.init()
		
		publicTerminationHandler = super.terminationHandler
		updateTerminationHandler()
	}
	
	deinit {
		Conf.logger?.trace("Deinit of an XcodeToolsProcess")
	}
	
	override var terminationHandler: ((Process) -> Void)? {
		get {super.terminationHandler}
		set {publicTerminationHandler = newValue; updateTerminationHandler()}
	}
	
	private var publicTerminationHandler: ((Process) -> Void)?
	
	/**
	 Sets super’s terminationHandler to nil if both private and public termination handlers are nil, otherwise set it to call them. */
	private func updateTerminationHandler() {
		if privateTerminationHandler == nil && publicTerminationHandler == nil {
			super.terminationHandler = nil
		} else {
			super.terminationHandler = { process in
				(process as! XcodeToolsProcess).privateTerminationHandler?(process)
				(process as! XcodeToolsProcess).publicTerminationHandler?(process)
			}
		}
	}
	
}

#endif
