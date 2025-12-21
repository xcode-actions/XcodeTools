import Foundation

import ArgumentParser



@main
struct XctGen : AsyncParsableCommand {
	
	static let configuration = CommandConfiguration(
		abstract: "Generate files for Xcode projects",
		discussion: "This tool can generate useful code for your Xcode projects (e.g. autogenerate constants for your assets).",
		subcommands: [
			GenAssetsConstants.self
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
		var outputFormat = OutputFormat.text
		
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
					throw XctGenError(message: "Cannot convert JSON data to string")
				}
				print(jsonStr)
		}
	}
	
	@OptionGroup
	var xctVersionsOptions: XctGen.Options
	
}
