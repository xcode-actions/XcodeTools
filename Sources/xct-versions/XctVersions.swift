import Foundation

import ArgumentParser



@main
struct XctVersions : AsyncParsableCommand {
	
	static let configuration = CommandConfiguration(
		abstract: "Manage versions of Xcode projects",
		discussion: "This tool expects a specific setup of the Xcode projects in regard to the versioning (pretty much the only sane choice nowadays) and has a sub-command to validate said setup is correctly done.",
		subcommands: [
			ValidateSetup.self,
			GetVersions.self,
			SetBuildVersion.self,
			SetMarketingVersion.self
		]
	)
	
	struct Options : ParsableArguments {
		
		enum OutputFormat : String, CaseIterable, ExpressibleByArgument {
			
			case none
			case text
			case json
			case jsonPrettyPrinted = "json-pretty-printed"
			
		}
		
		@Option
		var pathToXcodeproj: String?
		
		@Option
		var targets = [String]()
		
		@Option
		var configurationNames = [String]()
		
		@Option
		var outputFormat = OutputFormat.text
		
		func targetMatches(_ targetName: String) -> Bool {
			guard !targets.isEmpty else {return true}
			return targets.contains(targetName)
		}
		
		func configurationNameMatches(_ configurationName: String) -> Bool {
			guard !configurationNames.isEmpty else {return true}
			return configurationNames.contains(configurationName)
		}
		
	}
	
	static func printOutput<OutputType>(_ output: OutputType, format: Options.OutputFormat) throws where OutputType : Encodable, OutputType : CustomStringConvertible {
		switch format {
			case .none:
				(/*nop*/)
				
			case .text:
				print(output, terminator: "")
				
			case .json, .jsonPrettyPrinted:
				let encoder = JSONEncoder()
				encoder.keyEncodingStrategy = .convertToSnakeCase
				encoder.outputFormatting = [.withoutEscapingSlashes]
				if format == .jsonPrettyPrinted {
					encoder.outputFormatting = encoder.outputFormatting.union([.prettyPrinted, .sortedKeys])
				}
				guard let jsonStr = try String(data: encoder.encode(output), encoding: .utf8) else {
					throw XctVersionsError(message: "Cannot convert JSON data to string")
				}
				print(jsonStr)
		}
	}
	
	@OptionGroup
	var xctVersionsOptions: XctVersions.Options
	
}
