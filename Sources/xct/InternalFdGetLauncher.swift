import Foundation
#if canImport(System)
import System
#else
import SystemPackage
#endif

import ArgumentParser
import CLTLogger
import CMacroExports
import Logging

#if os(Linux)
import CGNUSourceExports
#endif



struct InternalFdGetLauncher : ParsableCommand {
	
	static var configuration = CommandConfiguration(
		abstract: "Internal launcher for xct which receives a fd before launching the tool."
	)
	
	@Flag(inversion: .prefixedNo)
	var usePath = false
	
	/** If `nil` and `usePath` is `true`, we use `_PATH_DEFPATH`. */
	@Option
	var path: String?
	
	@Argument
	var toolName: String
	
	@Argument(parsing: .unconditionalRemaining)
	var toolArguments: [String] = []
	
	func run() throws {
//		Xct.logger.logLevel = .trace
		
		/* We need a bidirectionary dictionary… */
		var destinationFdToReceivedFd = [CInt: CInt]()
		var receivedFdToDestinationFd = [CInt: CInt]()
		try FileDescriptor.standardInput.closeAfter{
			/* First we read the number of fds to expect */
			let buffer = UnsafeMutableBufferPointer<Int32>.allocate(capacity: 1)
			defer {buffer.deallocate()}
			
			let rawBuffer = UnsafeMutableRawBufferPointer(buffer)
			guard try FileDescriptor.standardInput.read(into: rawBuffer) == rawBuffer.count else {
				/* TODO: Use an actual error */
				Xct.logger.error("unexpected number of bytes read from stdin")
				throw ExitCode(rawValue: 1)
			}
			let nFds = buffer.baseAddress!.pointee
			Xct.logger.trace("Will receive \(nFds) fds")
			
			/* Then we read the fds */
			for _ in 0..<nFds {
				let (receivedFd, destinationFd) = try receiveFd(from: FileDescriptor.standardInput.rawValue)
				Xct.logger.trace("Received fd \(receivedFd), with expected destination fd \(destinationFd))")
				/* As we have not closed any received fd yet, it should not be possible to received the same fd twice. */
				assert(receivedFdToDestinationFd[receivedFd] == nil)
				
				if let oldReceivedFd = destinationFdToReceivedFd[destinationFd] {
					Xct.logger.warning("Internal Launcher: Received expected destination fd \(destinationFd) more than once! Caller did a mistake. Latest received fd (\(receivedFd) for now) wins.")
					
					/* We should close the old fd as we won’t be using it at all. */
					try FileDescriptor(rawValue: oldReceivedFd).close()
					
					/* Then remove it from the receivedFdToDestinationFd dictionary.
					 * No need to remove from destinationFdToReceivedFd (will be done just after this if). */
					assert(receivedFdToDestinationFd[oldReceivedFd] == destinationFd)
					receivedFdToDestinationFd.removeValue(forKey: oldReceivedFd)
				}
				
				receivedFdToDestinationFd[receivedFd] = destinationFd
				destinationFdToReceivedFd[destinationFd] = receivedFd
			}
			Xct.logger.trace("Received all fds")
		}
		
		/* We may modify destinationFdToReceivedFd values, so no (key, value) iteration type. */
		for destinationFd in destinationFdToReceivedFd.keys {
			let receivedFd = destinationFdToReceivedFd[destinationFd]!
			defer {
				assert(receivedFdToDestinationFd[receivedFd] == destinationFd)
				receivedFdToDestinationFd.removeValue(forKey: receivedFd)
			}
			
			/* dup2 takes care of this case, but needed later. */
			guard destinationFd != receivedFd else {continue}
			
			if let destinationFdToUpdate = receivedFdToDestinationFd[destinationFd] {
				/* If the current destination fd is in the received fds, we must dup the destination fd. */
				let newReceivedFd = dup(destinationFd)
				guard newReceivedFd != -1 else {
					/* TODO: Use an actual error */
					throw ExitCode(rawValue: 1)
				}
				/* No need to close the destination fd as dup2 will do it. */
				receivedFdToDestinationFd.removeValue(forKey: destinationFd)
				receivedFdToDestinationFd[newReceivedFd] = destinationFdToUpdate
				destinationFdToReceivedFd[destinationFdToUpdate] = newReceivedFd
			}
			
			guard dup2(receivedFd, destinationFd) != -1 else {
				/* TODO: Use an actual error */
				throw ExitCode(rawValue: 1)
			}
			guard close(receivedFd) == 0 else {
				/* TODO: Use an actual error */
				throw ExitCode(rawValue: 1)
			}
		}
		
		try withCStrings([toolName] + toolArguments, scoped: { cargs in
			Xct.logger.trace("exec’ing \(toolName)")
			let ret: Int32
			if usePath {
#if !os(Linux)
				/* The P implementation of exec searches for the binary path in the given search path.
				 * The v means we pass an array to exec (as opposed to the variadic exec variant, which is not available in Swift anyway). */
				ret = execvP(toolName, path ?? _PATH_DEFPATH, cargs)
#else
				/* execvP does not exist on Linux, so we simulate it by
				 *  copying current env in a new buffer,
				 *  modifying PATH, and
				 *  using execvpe which allows both passing an environment and using PATH. */
				
				/* First we count the number of env vars */
				var countEnv = 0
				var curEnv = environ
				while let _ = curEnv.pointee {
					curEnv = curEnv.successor()
					countEnv += 1
				}
				
				/* Then allocate the new env array */
				let newEnv = UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>.allocate(capacity: countEnv + 1)
				newEnv.initialize(repeating: nil, count: countEnv + 1)
				defer {
					var curEnv = newEnv
					/* We assume there are no “holes” in newEnv */
					while let e = curEnv.pointee {
						curEnv = curEnv.successor()
						e.deallocate()
					}
					newEnv.deallocate()
				}
				
				/* And copy the values */
				for i in 0..<countEnv {
					/* Force-unwrap-proof because of the way countEnv is inited. */
					newEnv.advanced(by: i).pointee = strdup(environ.advanced(by: i).pointee!)
					guard newEnv.advanced(by: i).pointee != nil else {
						/* TODO: Which error do we do? */throw ExitCode(errno)
					}
				}
				
				/* Finally set PATH */
				setenv("PATH", path ?? _PATH_DEFPATH, 1)
				/* And exec the process */
				ret = xct_execvpe(toolName, cargs, newEnv)
#endif
			} else {
				ret = execv(toolName, cargs)
			}
			assert(ret != 0, "exec should not return if it was successful.")
			Xct.logger.error("Error running executable \(toolName): \(Errno(rawValue: errno).description)")
			/* TODO: Is this the exit code we really want? */throw ExitCode(errno)
		})
		
		fatalError("Unreachable code reached")
	}
	
	/* <https://stackoverflow.com/a/28005250> (last variant). */
	private func receiveFd(from socket: CInt) throws -> (receivedFd: CInt, expectedDestinationFd: CInt) {
		var msg = msghdr()
		
		/* We receive the destination fd (a simple CInt) in an iovec. */
		let iovBase = UnsafeMutablePointer<CInt>.allocate(capacity: 1)
		defer {iovBase.deallocate()}
		iovBase.initialize(to: -1)
		
		let ioPtr = UnsafeMutablePointer<iovec>.allocate(capacity: 1)
		defer {ioPtr.deallocate()}
		ioPtr.initialize(to: iovec(iov_base: iovBase, iov_len: MemoryLayout<CInt>.size))
		
		msg.msg_iov = ioPtr
		msg.msg_iovlen = 1
		
		/* Ancillary data. This is where we receive the actual fd. */
		let controlBufSize = 256
		let controlBuf = UnsafeMutablePointer<Int8>.allocate(capacity: controlBufSize)
		defer {controlBuf.deallocate()}
		controlBuf.assign(repeating: 0, count: controlBufSize)
		msg.msg_control = UnsafeMutableRawPointer(controlBuf)
#if !os(Linux)
		msg.msg_controllen = socklen_t(controlBufSize)
#else
		msg.msg_controllen = Int(controlBufSize)
#endif
		
		let receivedBytes = recvmsg(socket, &msg, 0)
		guard receivedBytes >= 0 else {
			/* The socket is not a TCP socket, so we cannot know whether the connexion was closed before reading it.
			 * We used to check the error after reading and ignore connection reset errors.
			 * On Linux however, recvmsg simply blocks when there are no more fds to read.
			 * So now we send the number of fds to expect beforehand, and we should always be able to read all the fds.
			 * For posterity, the test was this:
			 *    let ok = (receivedBytes == 0 || errno == ECONNRESET)
			 * And we returned nil if ok was true. */
			/* TODO: Is it ok to log in this context? I’d say probably yeah, but too tired to validate now. */
			Xct.logger.error("cannot read from socket: \(Errno(rawValue: errno))")
			/* TODO: Use an actual error */throw ExitCode(rawValue: 1)
		}
		
		var receivedFd: Int32 = -1
		guard let cmsg = XCT_CMSG_FIRSTHDR(&msg), cmsg.pointee.cmsg_type == SCM_RIGHTS else {
			/* TODO: Use an actual error (internal error) */
			throw ExitCode(rawValue: 1)
		}
		memmove(&receivedFd, XCT_CMSG_DATA(cmsg), MemoryLayout.size(ofValue: receivedFd))
		
		let expectedDestinationFd = iovBase.pointee
		
		guard receivedFd != -1, expectedDestinationFd != -1 else {
			/* TODO: Use an actual error (internal error) */
			throw ExitCode(rawValue: 1)
		}
		return (receivedFd: receivedFd, expectedDestinationFd: expectedDestinationFd)
	}
	
	/* If needed. From <https://stackoverflow.com/a/12340767>. */
	private func isValidFileDescriptor(_ fd: FileDescriptor) -> Bool {
		return fcntl(fd.rawValue, F_GETFL) != -1 || errno != EBADF
	}
	
}
