import Foundation
#if canImport(System)
import System
#else
import SystemPackage
#endif

/* I cannot update ArgumentParser because of swift-driver… */
@preconcurrency import ArgumentParser
import XcodeTools
import XibLoc

import Logging
import CLTLogger



struct GenAssetsConstants : ParsableCommand {
	
	static let configuration = CommandConfiguration(
		commandName: "assets-constants",
		abstract: "Generates the constants from the xcasset.",
		discussion: "Generate a Swift file containing constants derived from the xcassets in your project."
	)
	
	@OptionGroup
	var xctGenOptions: XctGen.Options
	
	@Argument
	var generatedFilePathTemplate: String
	
	@Argument
	var generatedParentFilePathTemplate: String
	
	@Argument
	var targets = [String]()
	
	func run() throws {
		LoggingSystem.bootstrap{ _ in var ret = CLTLogger(); ret.logLevel = .info; return ret }
		
		let project = try Project(xcodeprojPath: xctGenOptions.pathToXcodeproj)
		let targetToConstants: [Target: Constants] = try {
			var res = [Target: Constants]()
			for target in try project.getTargets() {
				let targetName = try target.getName()
				let isSPMTarget = (target.spmTarget != nil)
				guard targets.isEmpty || targets.contains(targetName) else {
					continue
				}
				guard !(target.spmTarget?.sourcesContainsObjCFiles ?? false) else {
//					Conf.logger?.info("Skipped target \(targetName) which contains ObjC.")
					continue
				}
				
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
				
				/* Assign Constants to res. */
				res[target] = Constants(isSPMTarget: isSPMTarget, colors: colorNames)
			}
			return res
		}()
		for (target, constants) in targetToConstants {
			let resolvingInfo = try Str2StrXibLocInfo(replacements: ["|": target.getName()], orderedReplacements: ["<:>": !constants.isSPMTarget ? 0 : 1])!
			let relativeParentDest = generatedParentFilePathTemplate.applying(xibLocInfo: resolvingInfo)
			let relativeRootDest = generatedFilePathTemplate.applying(xibLocInfo: resolvingInfo)
			
#warning("No filter on Tests…")
			let parentConstants = try project
				.getDependents(of: target)
				.filter{ try !$0.getName().contains("Tests") }
				.compactMap{ targetToConstants[$0] }
				.reduce(into: (first: true, constants: Constants(isSPMTarget: constants.isSPMTarget)), { current, new in
					if current.first {
						current.first = false
						current.constants.colors = new.colors
					} else {
						current.constants.colors = current.constants.colors.filter{ new.colors.keys.contains($0.key) }
					}
				}).constants
			
			try       constants.writeColors(to: URL(fileURLWithPath:   relativeRootDest, relativeTo: target.getSourcesRoot()), isParent: false)
			try parentConstants.writeColors(to: URL(fileURLWithPath: relativeParentDest, relativeTo: target.getSourcesRoot()), isParent: true)
		}
	}
	
	struct Constants {
		
		var isSPMTarget: Bool
		
		/* Key is swift color name, value is actual color name. */
		var colors: [String: String] = [:]
		
		func writeColors(to dest: URL, isParent: Bool) throws {
			if colors.isEmpty {
				_ = try? FileManager.default.removeItem(at: dest)
			} else {
				var generatedFile = """
					/* ********************************************************
					   ***** AUTO-GENERATED FILE; DO NOT MODIFY MANUALLY! *****
					   ******************************************************** */
					
					import Foundation
					
					
					#if canImport(SwiftUI)
					import SwiftUI
					
					internal enum \(!isParent ? "Colors" : "ParentColors") {
						
					"""
				for (swiftColorName, colorName) in colors.sorted(by: { $0.key < $1.key }) {
					var openQuote = "\""
					var closeQuote = "\""
					while colorName.contains(openQuote) || colorName.contains(closeQuote) {
						openQuote = "#" + openQuote
						closeQuote = closeQuote + "#"
					}
					generatedFile += #"""
						
							@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *) internal static let \#(swiftColorName) = Color(\#(openQuote)\#(colorName)\#(closeQuote)\#((!isSPMTarget || isParent) ? "" : ", bundle: .module"))
						"""#
				}
				generatedFile += """
					
						
					}
					
					#endif
					
					
					#if canImport(AppKit)
					import AppKit
					
					internal enum \(!isParent ? "NSColors" : "ParentNSColors") {
						
					"""
				for (swiftColorName, colorName) in colors.sorted(by: { $0.key < $1.key }) {
					var openQuote = "\""
					var closeQuote = "\""
					while colorName.contains(openQuote) || colorName.contains(closeQuote) {
						openQuote = "#" + openQuote
						closeQuote = closeQuote + "#"
					}
					generatedFile += #"""
						
							internal static let \#(swiftColorName) = NSColor(named: \#(openQuote)\#(colorName)\#(closeQuote)\#((!isSPMTarget || isParent) ? "" : ", bundle: .module"))!
						"""#
				}
				generatedFile += """
					
						
					}
					
					#endif
					
					
					#if canImport(UIKit)
					import UIKit
					
					internal enum \(!isParent ? "UIColors" : "ParentUIColors") {
						
					"""
				for (swiftColorName, colorName) in colors.sorted(by: { $0.key < $1.key }) {
					var openQuote = "\""
					var closeQuote = "\""
					while colorName.contains(openQuote) || colorName.contains(closeQuote) {
						openQuote = "#" + openQuote
						closeQuote = closeQuote + "#"
					}
					generatedFile += #"""
						
							internal static let \#(swiftColorName) = UIColor(named: \#(openQuote)\#(colorName)\#(closeQuote)\#((!isSPMTarget || isParent) ? "" : ", in: .module, compatibleWith: nil"))!
						"""#
				}
				generatedFile += """
					
						
					}
					
					#endif
					
					"""
				try FileManager.default.createDirectory(at: dest.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
				try Data(generatedFile.utf8).write(to: dest)
			}
		}
		
	}
	
}
