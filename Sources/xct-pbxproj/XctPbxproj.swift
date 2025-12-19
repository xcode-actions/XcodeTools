import Foundation

import ArgumentParser
import CLTLogger
import Logging



@main
struct XctPbxproj : ParsableCommand {
	
	static let configuration = CommandConfiguration(
		abstract: "Interact with pbxproj files",
		discussion: "This tool contains a few utilities to interact with pbxproj files.",
		subcommands: [
			ListTargets.self,
			Sanitize.self
		]
	)
	
	static func bootstrap() {
		LoggingSystem.bootstrap{ _ in CLTLogger() }
	}
	
	static let logger: Logger = {
		var ret = Logger(label: "main")
		ret.logLevel = .debug
		return ret
	}()
	
	struct Options : ParsableArguments {
		
		@Option
		var pathToXcodeproj: String?
		
	}
	
}
