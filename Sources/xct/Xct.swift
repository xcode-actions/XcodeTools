import Foundation
import SystemPackage

import ArgumentParser
import CLTLogger
import Logging



/* Might be useful some day: <https://stackoverflow.com/a/26973384>. */
@main
struct Xct : AsyncParsableCommand {
	
	static let execPathEnvVarName = "XCT_EXEC_PATH"
	
	static let configuration = CommandConfiguration(
		abstract: "Xcode Tools – Manage, build, sign and deploy your Xcode projects.",
		discussion: "xct is a simple launcher for other XcodeTools binaries (xct-*). For instance, instead of calling “xct-versions”, you can call “xct versions”."
	)
	
	static let logger: Logger = {
		var ret = Logger(label: "main")
		ret.logLevel = .debug
		return ret
	}()
	
	@Option(help: "Set the path to the core xct programs.", completion: .directory)
	var execPath: String = Self.defaultExecPath
	
	@Option(name: .customShort("C"), help: ArgumentHelp("Change working directory before calling the tool.", valueName: "path"), completion: .directory)
	var workdir: String?
	
	@Argument(completion: .custom(toolNameCompletion))
	var toolName: String
	
	@Argument(parsing: .captureForPassthrough)
	var toolArguments: [String] = []
	
	func run() throws {
		LoggingSystem.bootstrap{ _ in CLTLogger() }
		
		let absoluteExecPath = URL(fileURLWithPath: execPath).path
		if toolName != "internal-fd-get-launcher" {
			/* We force the XCT_EXEC_PATH env to the current exec path if current tool name is not "internal-fd-get-launcher".
			 * This is because some subprograms need the XCT_EXEC_PATH and expect it to be defined.
			 * We do not define it for the internal launcher because the spawn* function family guarantees
			 * the env is not modified when the executable is launched, even when sending fds. */
			guard setenv(Xct.execPathEnvVarName, absoluteExecPath, 1) == 0 else {
				Xct.logger.error("Error modifying \(Xct.execPathEnvVarName): \(Errno(rawValue: errno).description)")
				throw ExitCode(errno)
			}
		}
		
		/* Change current workdir if asked */
		if let workdir = workdir {
			guard FileManager.default.changeCurrentDirectoryPath(workdir) else {
				Xct.logger.error("Cannot set current directory to \(workdir)")
				throw ExitCode(1)
			}
		}
		
		/* We cannot use a subcommand (parsed by the main command instead of the subcommand,
		 *  because the main command expects a generic tool name arg,
		 *  which cannot be distinguished from the subcommand). */
		switch toolName {
			case "generate-meta-completion-script": return GenerateMetaCompletionScript.main(toolArguments)
			default:                                try launchGenericTool(absoluteExecPath: absoluteExecPath)
		}
	}
	
	/* Bundle.main.bundleURL.path seem to correctly reflect the path of the executable that was launched:
	 *    - Changes when executable location does (path not hard-coded in bin);
	 *    - Does _not_ resolve symlink when launched executable is a symlink.
	 *      Ex: /usr/local/bin/xct is link to /opt/brew/bin/xct.
	 *          When /usr/local/bin/xct is launched, Bundle.main.bundleURL.path is the usr one, not the opt one (this is what we want). */
	private static var defaultExecPath: String {
		return getenv(Xct.execPathEnvVarName).flatMap{ String(cString: $0) } ?? Bundle.main.bundleURL.path
	}
	
	private static func updateEnvFromArgs(_ args: [String]) {
		func checkShortArgValue(expected: Character, i: inout Int) -> String? {
			let arg = args[i]
			
			guard
				arg.first == "-",                               /* Current arg is an option */
				let nextChar = arg.dropFirst().first,           /* Current arg is not a single - */
				nextChar != "-",                                /* Current arg is not a long option */
				let charPosition = arg.firstIndex(of: expected) /* Current arg contains the option we seek */
			else {
				return nil
			}
			
			if charPosition == arg.index(before: arg.endIndex) {
				/* The value we seek is the next arg */
				if args.index(after: i) < args.endIndex {
					i = args.index(after: i)
					return args[i]
				} else {
					/* Note: This case should never happen as
					 *  we’re called from ArgumentParser,
					 *  in the completion module for the tool name, and
					 *  in that context we shouldn’t be able to have a last argument being the arg we seek without value. */
					return nil
				}
			} else {
				/* The value we seek is after the char we found.
				 * Funily it seems ArgumentParser does not support this use case. */
				return String(arg[arg.index(after: charPosition)...])
			}
		}
		
		func checkLongArgValue(expected: String, i: inout Int) -> String? {
			let arg = args[i]
			let fullNoEqual = "--" + expected
			let fullWithEqual = "--" + expected + "="
			
			if arg == fullNoEqual {
				if args.index(after: i) < args.endIndex {
					i = args.index(after: i)
					return args[i]
				} else {
					/* Note: This case should never happen as
					 *  we’re called from ArgumentParser,
					 *  in the completion module for the tool name, and
					 *  in that context we shouldn’t be able to have a last argument being the arg we seek without value. */
					return nil
				}
			}
			if let r = arg.range(of: fullWithEqual), r.lowerBound == arg.startIndex {
				return String(arg[r.upperBound...])
			}
			return nil
		}
		
//		FileHandle.standardError.write(Data("\n".utf8))
//		FileHandle.standardError.write(Data("args \(args)\n".utf8))
		var i = args.startIndex
		while i < args.endIndex {
			defer {i = args.index(after: i)}
			
			guard args[i] != "--" else {
				/* End of the options; we do not go further. */
				break
			}
			
			if let path = checkShortArgValue(expected: "C", i: &i) {
//				FileHandle.standardError.write(Data("got path \(path)\n".utf8))
				_ = FileManager.default.changeCurrentDirectoryPath(path)
			}
			if let execPath = checkLongArgValue(expected: "exec-path", i: &i) {
//				FileHandle.standardError.write(Data("got exec path \(execPath)\n".utf8))
				_ = setenv(execPathEnvVarName, execPath, 1)
			}
		}
	}
	
	private static func listExecutableSuffixesIn(_ dir: String, prefix: String) throws -> [String] {
		let fm = FileManager.default
		guard let realpathDir = realpath(dir.isEmpty ? "." : dir, nil) else {
			throw Errno(rawValue: errno)
		}
		return try fm.contentsOfDirectory(at: URL(fileURLWithPath: String(cString: realpathDir)), includingPropertiesForKeys: [.isExecutableKey, .isRegularFileKey, .isDirectoryKey], options: [])
			.compactMap{ url in
				let path = url.lastPathComponent
				guard let r = path.range(of: prefix), r.lowerBound == path.startIndex else {
					return nil
				}
				guard path.hasPrefix(prefix) else {
					return nil
				}
				let resVal = try url.resourceValues(forKeys: Set(arrayLiteral: .isExecutableKey, .isRegularFileKey, .isDirectoryKey))
				/* We should be able to test if the file is a regular file.
				 * If we do it, it works when compiled in debug mode, otherwise it does not!
				 * To workaround this, we check if the file is not a folder instead. */
				guard /*resVal.isRegularFile ?? false, */!(resVal.isDirectory ?? true), resVal.isExecutable ?? false else {
					return nil
				}
				return String(path[r.upperBound...])
			}
	}
	
	private static func toolNameCompletion(_ args: [String]) -> [String] {
		updateEnvFromArgs(args)
		let execPath = Self.defaultExecPath
		let path = getenv("PATH").flatMap{ String(cString: $0) } ?? ""
		let suffixes = Set(([execPath] + path.split(separator: ":", omittingEmptySubsequences: false).map(String.init)).flatMap{ (try? listExecutableSuffixesIn($0, prefix: "xct-")) ?? [] })
		return suffixes.sorted()
	}
	
	private func launchGenericTool(absoluteExecPath: String) throws -> Never {
		/* We will use the PATH in env, but w/ the exec path search first
		 * (tested with git which apparently puts its internal tools first in the search). */
		let searchPath = getenv("PATH").flatMap{ String(cString: $0) } ?? ""
		let newSearchPath = absoluteExecPath + (searchPath.isEmpty ? "" : ":") + searchPath
		
		let fullToolName = "xct-" + toolName
		try withCStrings([fullToolName] + toolArguments, scoped: { cargs in
			/* The P implementation of exec searches for the binary path in the given search path.
			 * The v means we pass an array to exec (as opposed to the variadic exec variant, which is not available in Swift anyway). */
#if !os(Linux)
			let ret = execvP(fullToolName, newSearchPath, cargs)
#else
			/* TODO: Set PATH to newSearchPath (and document it) */
			let ret = execvp(fullToolName, cargs)
#endif
			assert(ret != 0, "exec should not return if it was successful.")
			Xct.logger.error("Error running executable \(fullToolName): \(Errno(rawValue: errno).description)")
			throw ExitCode(errno)
		})
		
		fatalError("Unreachable code reached")
	}
	
}
