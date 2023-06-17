import Foundation
#if canImport(System)
import System
#else
import SystemPackage
#endif

import ArgumentParser
import CLTLogger
import Logging



@main
struct Hagvtool : ParsableCommand {
	
	static var configuration = CommandConfiguration(
		abstract: "Deprecated. This tool is now a part of xct. You can use it by running \"xct versions\"."
	)
	
	@Argument
	var arguments: [String] = []
	
	func run() throws {
		LoggingSystem.bootstrap{ _ in CLTLogger() }
		let logger = Logger(label: "main")
		
		logger.error("hagvtool has been deprecated. Please use \"xct versions\" instead.")
		try withCStrings(["xct-versions"] + arguments, scoped: { cargs in
			/* The p implementation of exec searches for the binary path in PATH.
			 * The v means we pass an array to exec (as opposed to the variadic exec variant, which is not available in Swift anyway). */
#if !os(Linux)
			let ret = execvP("xct-versions", URL(fileURLWithPath: CommandLine.arguments[0]).deletingLastPathComponent().path, cargs)
#else
			/* TODO: Add CommandLine.arguments[0] (minus last path component) in PATH */
			let ret = execvp("xct-versions", cargs)
#endif
			assert(ret != 0, "exec should not return if it was successful.")
			logger.error("Error running executable xct-versions: \(Errno(rawValue: errno).description)")
			throw ExitCode(errno)
		})
	}
	
	/* From <https://gist.github.com/dduan/d4e967f3fc2801d3736b726cd34446bc>. */
	private func withCStrings(_ strings: [String], scoped: ([UnsafeMutablePointer<CChar>?]) throws -> Void) rethrows {
		let cStrings = strings.map{ strdup($0) }
		try scoped(cStrings + [nil])
		cStrings.forEach{ free($0) }
	}
	
}
