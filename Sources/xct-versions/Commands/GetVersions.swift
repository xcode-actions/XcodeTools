import Foundation

import ArgumentParser
import XcodeProj



struct GetVersions : ParsableCommand {
	
	@OptionGroup
	var xctVersionsOptions: XctVersions.Options
	
	@Flag
	var failOnMultipleBuildVersions = false
	
	@Flag
	var failOnMultipleMarketingVersions = false
	
	@Flag(help: #"An alias for "--fail-on-multiple-build-versions --fail-on-multiple-marketing-versions""#)
	var failOnMultipleVersions = false
	
	func run() throws {
		let xcodeproj = try XcodeProj(path: xctVersionsOptions.pathToXcodeproj, autodetectInFolderAtPath: ".")
		let versions = try xcodeproj.iterateCombinedBuildSettingsOfTargets(matchingOptions: xctVersionsOptions){ target, targetName, configuration, configurationName, combinedBuildSettings -> [Output.Version] in
			let plist = try combinedBuildSettings.infoPlistResolved(xcodeprojURL: xcodeproj.xcodeprojURL)
			return [
				Output.Version(
					versionType: .buildVersion,
					targetName: targetName,
					configurationName: configurationName,
					versionSource: .buildConfiguration,
					value: combinedBuildSettings["CURRENT_PROJECT_VERSION"]
				),
				Output.Version(
					versionType: .marketingVersion,
					targetName: targetName,
					configurationName: configurationName,
					versionSource: .buildConfiguration,
					value: combinedBuildSettings["MARKETING_VERSION"]
				),
				plist.flatMap{ plist in
					Output.Version(
						versionType: .buildVersion,
						targetName: targetName,
						configurationName: configurationName,
						versionSource: .plist,
						value: plist["CFBundleVersion"] as? String ?? ""
					)
				},
				plist.flatMap{ plist in
					Output.Version(
						versionType: .marketingVersion,
						targetName: targetName,
						configurationName: configurationName,
						versionSource: .plist,
						value: plist["CFBundleShortVersionString"] as? String ?? ""
					)
				}
			].compactMap{ $0 }
		}.flatMap{ $0 }
		
		let output = Output(versions: versions)
		try XctVersions.printOutput(output, format: xctVersionsOptions.outputFormat)
		
		if failOnMultipleBuildVersions || failOnMultipleVersions {
			guard output.reducedBuildVersionForAll != nil else {
				throw ExitCode(1)
			}
		}
		if failOnMultipleMarketingVersions || failOnMultipleVersions {
			guard output.reducedMarketingVersionForAll != nil else {
				throw ExitCode(1)
			}
		}
	}
	
	private struct Output : Encodable, CustomStringConvertible {
		
		struct Version : Encodable {
			
			enum VersionType : String, Encodable {
				
				case marketingVersion = "MarketingVersion"
				case buildVersion = "BuildVersion"
				
			}
			
			enum VersionSource : String, Encodable {
				
				case buildConfiguration = "config"
				case plist
				
			}
			
			var versionType: VersionType
			
			var targetName: String
			var configurationName: String
			var versionSource: VersionSource
			
			var value: String
			
		}
		
		var versions: [Version]
		
		@NullEncodable
		var reducedBuildVersionForAll: String?
		var reducedBuildVersionPerTargets: [String: String?]
		
		@NullEncodable
		var reducedMarketingVersionForAll: String?
		var reducedMarketingVersionPerTargets: [String: String?]
		
		var description: String {
			var lines = [String]()
			
			lines += versions.map{ version in
				return version.versionType.rawValue.bracketEscaped() + "[" + version.targetName.bracketEscaped() + "][" + version.configurationName.bracketEscaped() + "][" + version.versionSource.rawValue.bracketEscaped() + "] = \"" + version.value.quoteEscaped() + "\""
			}
			
			for (targetName, version) in reducedBuildVersionPerTargets.map({ $0 }) {
				guard let version = version else {
					continue
				}
				lines.append(Version.VersionType.buildVersion.rawValue.bracketEscaped() + "[" + targetName.bracketEscaped() + "] = \"" + version.quoteEscaped() + "\"")
			}
			
			for (targetName, version) in reducedMarketingVersionPerTargets.map({ $0 }) {
				guard let version = version else {
					continue
				}
				lines.append(Version.VersionType.marketingVersion.rawValue.bracketEscaped() + "[" + targetName.bracketEscaped() + "] = \"" + version.quoteEscaped() + "\"")
			}
			
			if let v = reducedBuildVersionForAll {
				lines.append(Version.VersionType.buildVersion.rawValue.bracketEscaped() + " = \"" + v.quoteEscaped() + "\"")
			}
			
			if let v = reducedMarketingVersionForAll {
				lines.append(Version.VersionType.marketingVersion.rawValue.bracketEscaped() + " = \"" + v.quoteEscaped() + "\"")
			}
			
			return lines.joined(separator: "\n") + "\n"
		}
		
		init(versions vs: [Version]) {
			let ·versions = vs.sorted{ v1, v2 in
				if v1.versionType.rawValue < v2.versionType.rawValue {return true}
				if v1.versionType.rawValue > v2.versionType.rawValue {return false}
				
				if v1.targetName < v2.targetName {return true}
				if v1.targetName > v2.targetName {return false}
				
				if v1.configurationName < v2.configurationName {return true}
				if v1.configurationName > v2.configurationName {return false}
				
				if v1.versionSource.rawValue < v2.versionSource.rawValue {return true}
				if v1.versionSource.rawValue > v2.versionSource.rawValue {return false}
				
				return true
			}
			
			let buildVersions     = ·versions.filter{ $0.versionType == .buildVersion     }
			let marketingVersions = ·versions.filter{ $0.versionType == .marketingVersion }
			
			let ·reducedBuildVersionForAll     =     buildVersions.reduce(    buildVersions.first?.value, { $0 == $1.value ? $0 : nil })
			let ·reducedMarketingVersionForAll = marketingVersions.reduce(marketingVersions.first?.value, { $0 == $1.value ? $0 : nil })
			
			let ·reducedBuildVersionPerTargets: [String: String?] = Dictionary(Set(buildVersions.map{ $0.targetName }).map{ targetName in
				let filtered = buildVersions.filter{ $0.targetName == targetName }
				return (targetName, filtered.reduce(filtered.first?.value, { $0 == $1.value ? $0 : nil }) )
			}, uniquingKeysWith: { _,_ in fatalError("Internal Error: Got the same target twice when merging build versions. This should not be possible.") })
			let ·reducedMarketingVersionPerTargets: [String: String?] = Dictionary(Set(marketingVersions.map{ $0.targetName }).map{ targetName in
				let filtered = marketingVersions.filter{ $0.targetName == targetName }
				return (targetName, filtered.reduce(filtered.first?.value, { $0 == $1.value ? $0 : nil }) )
			}, uniquingKeysWith: { _,_ in fatalError("Internal Error: Got the same target twice when merging marketing versions. This should not be possible.") })
			
			
			versions = ·versions
			
			reducedBuildVersionForAll = ·reducedBuildVersionForAll
			reducedMarketingVersionForAll = ·reducedMarketingVersionForAll
			
			reducedBuildVersionPerTargets = ·reducedBuildVersionPerTargets
			reducedMarketingVersionPerTargets = ·reducedMarketingVersionPerTargets
		}
		
	}
	
}
