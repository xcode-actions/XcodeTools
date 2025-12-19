import Foundation

import ArgumentParser

import XcodeProj



struct SetVersion {
	
	struct Options : ParsableArguments {
		
		enum InvalidSetupBehaviour : String, ExpressibleByArgument {
			
			case fail
			case fix
			
		}
		
		@Option
		var invalidSetupBehaviour = InvalidSetupBehaviour.fail
		
	}
	
	static func setVersion(options setVersionOptions: Options, generalOptions: XctVersions.Options, newVersion: String, xcodeproj: XcodeProj, plistKey: String, buildSettingKey: String) throws {
		let xcodeprojURL = xcodeproj.xcodeprojURL
		
		var xcconfigsToRewrite = [XCConfigRef]()
		try xcodeproj.iterateCombinedBuildSettingsOfTargets(matchingOptions: generalOptions){ target, targetName, configuration, configurationName, combinedBuildSettings in
			let generatesInfoPlistFile = (combinedBuildSettings["GENERATE_INFOPLIST_FILE"] == "YES")
			if let plistURL = combinedBuildSettings.infoPlistURL(xcodeprojURL: xcodeprojURL) {
				let plistData = try Data(contentsOf: plistURL)
				let deserializedPlist = try PropertyListSerialization.propertyList(from: plistData, options: [], format: nil)
				guard let deserializedPlistObject = deserializedPlist as? [String: Any] else {
					throw XctVersionsError(message: "Cannot deserialize plist file at URL \(plistURL) as a [String: Any].")
				}
				
				if !generatesInfoPlistFile {
					if deserializedPlistObject[plistKey] as? String != "$(\(buildSettingKey))" {
						switch setVersionOptions.invalidSetupBehaviour {
							case .fail:
								throw XctVersionsError(message: "Invalid \(plistKey) value in plist at path \(plistURL.path). Expected “$(\(buildSettingKey))”.")
								
							case .fix:
								var deserializedPlistObject = deserializedPlistObject
								deserializedPlistObject[plistKey] = "$(\(buildSettingKey))"
								let reserializedData = try PropertyListSerialization.data(fromPropertyList: deserializedPlistObject, format: .xml, options: 0)
								try reserializedData.write(to: plistURL)
						}
					}
				} else {
					if deserializedPlistObject[plistKey] as? String != nil {
						switch setVersionOptions.invalidSetupBehaviour {
							case .fail:
								throw XctVersionsError(message: "Invalid \(plistKey) value in plist at path \(plistURL.path). Expected key to be undefined.")
								
							case .fix:
								var deserializedPlistObject = deserializedPlistObject
								deserializedPlistObject.removeValue(forKey: plistKey)
								let reserializedData = try PropertyListSerialization.data(fromPropertyList: deserializedPlistObject, format: .xml, options: 0)
								try reserializedData.write(to: plistURL)
						}
					}
				}
			}
			
			let buildSettingsMatchingBuildVersion = combinedBuildSettings.buildSettings.filter{ $0.value.key.key == buildSettingKey }
			if setVersionOptions.invalidSetupBehaviour == .fail && buildSettingsMatchingBuildVersion.count > 1 {
				throw XctVersionsError(message: "\(buildSettingKey) is set in more than one place for target \(targetName).")
			}
			
			let resolvedCurrentBuildVersion = combinedBuildSettings.resolvedValue(for: BuildSettingKey(key: buildSettingKey))
			if setVersionOptions.invalidSetupBehaviour == .fail && resolvedCurrentBuildVersion?.sources.count ?? 0 > 1 {
				throw XctVersionsError(message: "\(buildSettingKey) uses variables for target \(targetName).")
			}
			
			/* First let’s remove all references to the current project version */
			for buildSetting in buildSettingsMatchingBuildVersion {
				switch buildSetting.value.location {
					case .none: throw XctVersionsError(message: "Internal error: Got a \(buildSettingKey) build setting without a location.")
					case .xcconfiguration(let config): config.rawBuildSettings?.removeValue(forKey: buildSettingKey)
					case .xcconfigFile(let xcconfig, lineID: let lineID, for: _):
						xcconfig.value.lines.removeValue(forKey: lineID)
						xcconfigsToRewrite.append(xcconfig)
				}
			}
			
			configuration.rawBuildSettings?[buildSettingKey] = newVersion
		}
		
		try xcodeproj.managedObjectContext.performAndWait{
			try xcodeproj.managedObjectContext.save()
			try Data(xcodeproj.pbxproj.stringSerialization(projectName: xcodeproj.projectName).utf8).write(to: xcodeproj.pbxprojURL)
			
			var rewrittenURLs = Set<URL>()
			for xcconfig in xcconfigsToRewrite {
				let url = xcconfig.value.sourceURL
				guard !rewrittenURLs.contains(url) else {continue}
				
				try Data(xcconfig.value.stringSerialization().utf8).write(to: url)
				rewrittenURLs.insert(url)
			}
		}
	}
	
}
