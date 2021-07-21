import Foundation

import ArgumentParser
import CLTLogger
import Logging
import SystemPackage



// Might be useful some day: https://stackoverflow.com/a/26973384
@main
struct Xct : ParsableCommand {
	
	static let execPathEnvVarName = "XCT_EXEC_PATH"
	
	static var configuration = CommandConfiguration(
		abstract: "Xcode Tools – Manage, build, sign and deploy your Xcode projects.",
		discussion: "xct is a simple launcher for other XcodeTools binaries (xct-*). For instance, instead of calling “xct-versions”, you can call “xct versions”."
	)
	
	static var logger: Logger = {
		var ret = Logger(label: "main")
		ret.logLevel = .debug
		return ret
	}()
	
	/* Bundle.main.bundleURL.path seem to correctly reflect the path of the
	 * executable that was launched:
	 *    - Changes when executable location does (path not hard-coded in bin);
	 *    - Does _not_ resolve symlink when launched executable is a symlink.
	 *      Ex: /usr/local/bin/xct is link to /opt/brew/bin/xct.
	 *          When /usr/local/bin/xct is launched, Bundle.main.bundleURL.path
	 *          is the usr one, not the opt one. (This is what we want.) */
	@Option(completion: .directory, help: "Set the path to the core xct programs.")
	var execPath: String = getenv(Xct.execPathEnvVarName).flatMap{ String(cString: $0) } ?? Bundle.main.bundleURL.path
	
	@Option(name: .customShort("C"), help: ArgumentHelp("Change working directory before calling the tool.", valueName: "path"), completion: .directory)
	var workdir: String?
	
	@Argument(completion: .custom(toolNameCompletion))
	var toolName: String
	
	@Argument(parsing: .unconditionalRemaining, completion: .custom(toolArgsCompletion))
	var toolArguments: [String] = []
	
	func run() throws {
		LoggingSystem.bootstrap{ _ in CLTLogger() }
		
		let absoluteExecPath = URL(fileURLWithPath: execPath).path
		/* We force the XCT_EXEC_PATH env to the current exec path (used by some subcommands). */
		guard setenv(Xct.execPathEnvVarName, absoluteExecPath, 1) == 0 else {
			Xct.logger.error("Error modifying \(Xct.execPathEnvVarName): \(Errno(rawValue: errno).description)")
			throw ExitCode(errno)
		}
		
		/* Change current working if asked */
		if let workdir = workdir {
			guard FileManager.default.changeCurrentDirectoryPath(workdir) else {
				Xct.logger.error("Cannot set current directory to \(workdir)")
				throw ExitCode(1)
			}
		}
		
		/* We cannot use a subcommand (parsed by the main command instead of the
		 * subcommand, because the main command expects a generic tool name arg,
		 * which cannot be distinguished from the subcommand). */
		switch toolName {
			case "internal-fd-get-launcher": return InternalFdGetLauncher.main(toolArguments)
			default:                         try launchGenericTool(absoluteExecPath: absoluteExecPath)
		}
	}
	
	private static func toolNameCompletion(_ args: [String]) -> [String] {
		/* Let’s “parse” the arguments to see if an exec-path has been given, then
		 * find all the xct-* tools available in the exec-path + PATH */
		
		return ["a", "b"]
	}
	
	private static func toolArgsCompletion(_ args: [String]) -> [String] {
		/* TODO */
		return ["a", "b"]
	}
	
	private func launchGenericTool(absoluteExecPath: String) throws -> Never {
		/* We will use the PATH in env, but w/ the exec path search first. */
		let searchPath = getenv("PATH").flatMap{ String(cString: $0) } ?? ""
		let newSearchPath = absoluteExecPath + (searchPath.isEmpty ? "" : ":") + searchPath
		
		let fullToolName = "xct-" + toolName
		try withCStrings([fullToolName] + toolArguments, scoped: { cargs in
			/* The P implementation of exec searches for the binary path in the
			 * given search path.
			 * The v means we pass an array to exec (as opposed to the variadic
			 * exec variant, which is not available in Swift anyway). */
			let ret = execvP(fullToolName, newSearchPath, cargs)
			assert(ret != 0, "exec should not return if it was successful.")
			Xct.logger.error("Error running executable \(fullToolName): \(Errno(rawValue: errno).description)")
			throw ExitCode(errno)
		})
		
		fatalError("Unreachable code reached")
	}
	
}
