import Foundation
#if canImport(System)
import System
#else
import SystemPackage
#endif

import ArgumentParser
import XcodeTools
import XibLoc

import Logging
import CLTLogger



struct GenAssetsConstants : ParsableCommand {
	
	static var configuration = CommandConfiguration(
		commandName: "assets-constants",
		abstract: "Generates the constants from the xcasset.",
		discussion: "Generate a Swift file containing constants derived from the xcassets in your project."
	)
	
	@OptionGroup
	var xctGenOptions: XctGen.Options
	
	@Argument
	var generatedFilePathTemplate: String
	
	@Argument
	var targets = [String]()
	
	func run() throws {
		LoggingSystem.bootstrap{ _ in var ret = CLTLogger(); return ret }
		
		let project = try Project(xcodeprojPath: xctGenOptions.pathToXcodeproj)
		for target in try project.getTargets() {
			let targetName = try target.getName()
			let isSPMTarget = (target.spmTarget != nil)
			guard targets.isEmpty || targets.contains(targetName) else {
				continue
			}
			guard !(target.spmTarget?.sourcesContainsObjCFiles ?? false) else {
//				Conf.logger?.info("Skipped target \(targetName) which contains ObjC.")
				continue
			}
			
			let resolvingInfo = Str2StrXibLocInfo(replacements: ["|": targetName], orderedReplacements: ["<:>": !isSPMTarget ? 0 : 1])!
			let relativeDest = generatedFilePathTemplate.applying(xibLocInfo: resolvingInfo)
			
			/* Get the color names. */
			var colorNames = [String: String]()
			for resourceURL in try target.getResources() {
				guard let xcassets = XcodeAssets(url: resourceURL) else {
					continue
				}
				try xcassets.iterateColorSets{ colorset in
					guard let swiftColorName = XcodeUtils.stringToSafeSwiftVarName(colorset.colorName) else {
						throw XctGenError(message: "Cannot convert color name \(colorset.colorName) to Swift-safe var name.")
					}
					guard colorNames[swiftColorName] == nil else {
						throw XctGenError(message: "Got normalized color name \(swiftColorName) twice!")
					}
					colorNames[swiftColorName] = colorset.colorName
				}
			}
			
			/* Write or remove assets file. */
			let dest = URL(fileURLWithPath: relativeDest, relativeTo: target.getSourcesRoot())
			if colorNames.isEmpty {
				_ = try? FileManager.default.removeItem(at: dest)
			} else {
				var generatedFile = """
					import Foundation
					import UIKit
					
					
					
					internal struct XctAssetsConstants {
						
					"""
				for (swiftColorName, colorName) in colorNames.sorted(by: { $0.key < $1.key }) {
					var openQuote = "\""
					var closeQuote = "\""
					while colorName.contains(openQuote) || colorName.contains(closeQuote) {
						openQuote = "#" + openQuote
						closeQuote = closeQuote + "#"
					}
					generatedFile += #"""
						
							internal static let \#(swiftColorName) = UIColor(named: \#(openQuote)\#(colorName)\#(closeQuote)\#(!isSPMTarget ? "" : ", in: .module, compatibleWith: nil"))!
						"""#
				}
				generatedFile += """
					
						
					}
					
					"""
				try FileManager.default.createDirectory(at: dest.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
				try Data(generatedFile.utf8).write(to: dest)
			}
		}
	}
	
}
