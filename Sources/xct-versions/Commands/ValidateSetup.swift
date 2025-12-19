import Foundation

import ArgumentParser
import XcodeProj



struct ValidateSetup : ParsableCommand {
	
	@OptionGroup
	var xctVersionsOptions: XctVersions.Options
	
	func run() throws {
		let xcodeproj = try XcodeProj(path: xctVersionsOptions.pathToXcodeproj, autodetectInFolderAtPath: ".")
		let xcodeprojURL = xcodeproj.xcodeprojURL
		
		let projectMessages = try xcodeproj.iterateCombinedBuildSettingsOfProject{ configuration, configurationName, combinedBuildSetting -> [Output.DiagnosticMessage] in
			let currentProjectVersionMessage = combinedBuildSetting.resolvedValue(for: BuildSettingKey(key: "CURRENT_PROJECT_VERSION")).flatMap{ v in
				Output.DiagnosticMessage(messageType: .projectBuildVersionSet, value: v.value, targetName: "", configurationName: configurationName)
			}
			let marketingVersionMessage = combinedBuildSetting.resolvedValue(for: BuildSettingKey(key: "MARKETING_VERSION")).flatMap{ v in
				Output.DiagnosticMessage(messageType: .projectMarketingVersionSet, value: v.value, targetName: "", configurationName: configurationName)
			}
			return [currentProjectVersionMessage, marketingVersionMessage].compactMap{ $0 }
		}.flatMap{ $0 }
		
		let targetMessages = try xcodeproj.iterateCombinedBuildSettingsOfTargets(matchingOptions: xctVersionsOptions){ target, targetName, configuration, configurationName, combinedBuildSettings -> [Output.DiagnosticMessage] in
			let generatesInfoPlistFile = (combinedBuildSettings["GENERATE_INFOPLIST_FILE"] == "YES")
			let plistMessages: [Output.DiagnosticMessage?]
			if let plist = try combinedBuildSettings.infoPlistRaw(xcodeprojURL: xcodeprojURL) {
				let bundleVersion = plist["CFBundleVersion"] as? String
				let shortVersionString = plist["CFBundleShortVersionString"] as? String
				
				if !generatesInfoPlistFile {
					let bundleVersionMessage = Output.DiagnosticMessage(messageType: .invalidCFBundleVersionInPlist, value: bundleVersion, targetName: targetName, configurationName: configurationName)
					let shortVersionStringMessage = Output.DiagnosticMessage(messageType: .invalidCFBundleShortVersionStringInPlist, value: shortVersionString, targetName: targetName, configurationName: configurationName)
					plistMessages = [
						(bundleVersion      != "$(CURRENT_PROJECT_VERSION)" ? bundleVersionMessage      : nil),
						(shortVersionString != "$(MARKETING_VERSION)"       ? shortVersionStringMessage : nil)
					]
				} else {
					let bundleVersionMessage = Output.DiagnosticMessage(messageType: .cfBundleVersionInPlistButGeneratesPlist, value: bundleVersion, targetName: targetName, configurationName: configurationName)
					let shortVersionStringMessage = Output.DiagnosticMessage(messageType: .cfBundleShortVersionStringInPlistButGeneratesPlist, value: shortVersionString, targetName: targetName, configurationName: configurationName)
					plistMessages = [
						(bundleVersion      != nil ? bundleVersionMessage      : nil),
						(shortVersionString != nil ? shortVersionStringMessage : nil)
					]
				}
			} else {
				plistMessages = []
			}
			
			var nonPlistMessages = [Output.DiagnosticMessage]()
			
			/* Versioning system check */
			let versioningSystem = combinedBuildSettings[BuildSettingKey(key: "VERSIONING_SYSTEM")]
			if versioningSystem != "apple-generic" {
				nonPlistMessages.append(Output.DiagnosticMessage(messageType: .invalidVersioningSystem, value: versioningSystem, targetName: targetName, configurationName: configurationName))
			}
			
			/* CURRENT_PROJECT_VERSION system check */
			let buildVersionSources = combinedBuildSettings.resolvedValue(for: BuildSettingKey(key: "CURRENT_PROJECT_VERSION"))?.sources
			switch (buildVersionSources, buildVersionSources?.last?.value.location.xcconfigFileURL) {
				case (nil, _):                  nonPlistMessages.append(Output.DiagnosticMessage(messageType: .buildVersionNotSet,             value: nil,                  targetName: targetName, configurationName: configurationName))
				case (_, let xcconfigFileURL?): nonPlistMessages.append(Output.DiagnosticMessage(messageType: .buildVersionSetInXCConfigFile,  value: xcconfigFileURL.path, targetName: targetName, configurationName: configurationName))
				default: (/*nop*/)
			}
			if buildVersionSources?.count ?? 0 > 1 {
				nonPlistMessages.append(Output.DiagnosticMessage(messageType: .buildVersionHasMultipleSources, value: nil, targetName: targetName, configurationName: configurationName))
			}
			if combinedBuildSettings.buildSettingsLevels.flatMap({ $0.value.settings }).filter({ $0.value.key.key == "CURRENT_PROJECT_VERSION" }).count > 1 {
				nonPlistMessages.append(Output.DiagnosticMessage(messageType: .buildVersionSetOnMultipleLevels, value: nil, targetName: targetName, configurationName: configurationName))
			}
			
			/* MARKETING_VERSION system check */
			let marketingVersionSources = combinedBuildSettings.resolvedValue(for: BuildSettingKey(key: "MARKETING_VERSION"))?.sources
			switch (marketingVersionSources, marketingVersionSources?.last?.value.location.xcconfigFileURL) {
				case (nil, _):                  nonPlistMessages.append(Output.DiagnosticMessage(messageType: .marketingVersionNotSet,             value: nil,                  targetName: targetName, configurationName: configurationName))
				case (_, let xcconfigFileURL?): nonPlistMessages.append(Output.DiagnosticMessage(messageType: .marketingVersionSetInXCConfigFile,  value: xcconfigFileURL.path, targetName: targetName, configurationName: configurationName))
				default: (/*nop*/)
			}
			if marketingVersionSources?.count ?? 0 > 1 {
				nonPlistMessages.append(Output.DiagnosticMessage(messageType: .marketingVersionHasMultipleSources, value: nil, targetName: targetName, configurationName: configurationName))
			}
			if combinedBuildSettings.buildSettingsLevels.flatMap({ $0.value.settings }).filter({ $0.value.key.key == "MARKETING_VERSION" }).count > 1 {
				nonPlistMessages.append(Output.DiagnosticMessage(messageType: .marketingVersionSetOnMultipleLevels, value: nil, targetName: targetName, configurationName: configurationName))
			}
			
			return (nonPlistMessages + plistMessages).compactMap{ $0 }
		}.flatMap{ $0 }
		
		let output = Output(messages: projectMessages + targetMessages)
		try XctVersions.printOutput(output, format: xctVersionsOptions.outputFormat)
		
		if !output.messages.isEmpty {
			throw ExitCode(1)
		}
		
//		try print(combinedBuildSettings.mapValues{ try $0.mapValues{ try $0[BuildSettingKey(serializedKey: "CURRENT_PROJECT_VERSION")] } })
//		try print(combinedBuildSettings.mapValues{ try $0.mapValues{ try $0[BuildSettingKey(serializedKey: "DYLIB_CURRENT_VERSION")] } })
//		try print(combinedBuildSettings.mapValues{ try $0.mapValues{ try $0[BuildSettingKey(serializedKey: "DYLIB_COMPATIBILITY_VERSION")] } })
//		try print(combinedBuildSettings.mapValues{ try $0.mapValues{ try $0[BuildSettingKey(serializedKey: "MARKETING_VERSION")] } })
//		try print(combinedBuildSettings.mapValues{ try $0.mapValues{ try $0[BuildSettingKey(serializedKey: "VERSION_INFO_BUILDER")] } })
//		try print(combinedBuildSettings.mapValues{ try $0.mapValues{ try $0[BuildSettingKey(serializedKey: "VERSION_INFO_EXPORT_DECL")] } })
//		try print(combinedBuildSettings.mapValues{ try $0.mapValues{ try $0[BuildSettingKey(serializedKey: "VERSION_INFO_FILE")] } })
//		try print(combinedBuildSettings.mapValues{ try $0.mapValues{ try $0[BuildSettingKey(serializedKey: "VERSION_INFO_PREFIX")] } })
//		try print(combinedBuildSettings.mapValues{ try $0.mapValues{ try $0[BuildSettingKey(serializedKey: "VERSION_INFO_SUFFIX")] } })
	}
	
	private struct Output : Encodable, CustomStringConvertible {
		
		struct DiagnosticMessage : Encodable {
			
			enum MessageType : String, Encodable, CaseIterable {
				
				case projectBuildVersionSet = "build-version-set-project-wide"
				case projectMarketingVersionSet = "marketing-version-set-project-wide"
				
				case invalidVersioningSystem = "invalid-versioning-system"
				
				case invalidCFBundleVersionInPlist = "invalid-CFBundleVersion-in-plist"
				case invalidCFBundleShortVersionStringInPlist = "invalid-CFBundleShortVersionString-in-plist"
				
				case cfBundleVersionInPlistButGeneratesPlist = "CFBundleVersion-in-plist-but-Xcode-generates-the-plist"
				case cfBundleShortVersionStringInPlistButGeneratesPlist = "CFBundleShortVersionString-in-plist-but-Xcode-generates-the-plist"
				
				case buildVersionNotSet = "build-version-not-set-in-target"
				case marketingVersionNotSet = "marketing-version-not-set-in-target"
				
				case buildVersionSetInXCConfigFile = "build-version-set-in-xcconfig-file"
				case marketingVersionSetInXCConfigFile = "marketing-version-set-in-xcconfig-file"
				
				case buildVersionHasMultipleSources = "build-version-has-variables"
				case marketingVersionHasMultipleSources = "marketing-version-has-variables"
				
				case buildVersionSetOnMultipleLevels = "build-version-set-in-more-than-one-place"
				case marketingVersionSetOnMultipleLevels = "marketing-version-set-in-more-than-one-place"
				
			}
			
			var messageType: MessageType
			var value: String?
			
			var targetName: String
			var configurationName: String
			
		}
		
		var messages: [DiagnosticMessage]
		
		var description: String {
			var previousWasSuccess = false
			
			let allCases = DiagnosticMessage.MessageType.allCases
			return allCases.enumerated().map{ (idx, c) in
				let isLast = (idx == allCases.count-1)
				switch c {
					case .projectBuildVersionSet:
						return descriptionForMessages(
							ofType: c,
							checkDescription: "Build version not set project-wide",
							failureExplanation: "The CURRENT_PROJECT_VERSION build setting should be set on a target per target basis, not project-wide.",
							failureToStringHandler: { "CURRENT_PROJECT_VERSION is set to “\($0.value ?? "<not set>")” at the project level for configuration “\($0.configurationName)”" },
							previousWasSuccess: &previousWasSuccess,
							isLast: isLast
						)
						
					case .projectMarketingVersionSet:
						return descriptionForMessages(
							ofType: c,
							checkDescription: "Marketing version not set project-wide",
							failureExplanation: "The MARKETING_VERSION build setting should be set on a target per target basis, not project-wide.",
							failureToStringHandler: { "MARKETING_VERSION is set to “\($0.value ?? "<not set>")” at the project level for configuration “\($0.configurationName)”" },
							previousWasSuccess: &previousWasSuccess,
							isLast: isLast
						)
						
					case .invalidVersioningSystem:
						return descriptionForMessages(
							ofType: c,
							checkDescription: "Versioning system",
							failureExplanation: "The versioning system should be set to “apple-generic” for all targets, though in practice not setting this build setting will not change much.",
							failureToStringHandler: { "Unexpected versioning system “\($0.value ?? "<not set>")” for target “\($0.targetName)” and configuration “\($0.configurationName)”" },
							previousWasSuccess: &previousWasSuccess,
							isLast: isLast
						)
						
					case .invalidCFBundleVersionInPlist:
						return descriptionForMessages(
							ofType: c,
							checkDescription: "CFBundleVersion value check (plist)",
							failureExplanation: """
								The CFBundleVersion value should be set to “$(CURRENT_PROJECT_VERSION)”.
								Of course, the actual version should be set using the CURRENT_PROJECT_VERSION key in the build settings (either directly in the project or using an xcconfig file).
								""",
							failureToStringHandler: { "Unexpected CFBundleVersion value “\($0.value ?? "<not set>")” in plist file for target “\($0.targetName)” and configuration “\($0.configurationName)”" },
							previousWasSuccess: &previousWasSuccess,
							isLast: isLast
						)
						
					case .invalidCFBundleShortVersionStringInPlist:
						return descriptionForMessages(
							ofType: c,
							checkDescription: "CFBundleShortVersionString value check (plist)",
							failureExplanation: """
								The CFBundleShortVersionString should be set to “$(MARKETING_VERSION)”.
								Of course, the actual version should be set using the MARKETING_VERSION key in the build settings (either directly in the project or using an xcconfig file).
								""",
							failureToStringHandler: { "Unexpected CFBundleShortVersionString value “\($0.value ?? "<not set>")” in plist file for target “\($0.targetName)” and configuration “\($0.configurationName)”" },
							previousWasSuccess: &previousWasSuccess,
							isLast: isLast
						)
						
					case .cfBundleVersionInPlistButGeneratesPlist:
						return descriptionForMessages(
							ofType: c,
							checkDescription: "CFBundleVersion value check (plist)",
							failureExplanation: """
								The CFBundleVersion value should be unset as your build settings defines that Xcode should generate the Info.plist file.
								The actual version should be set using the CURRENT_PROJECT_VERSION key in the build settings (either directly in the project or using an xcconfig file).
								""",
							failureToStringHandler: { "Unexpected CFBundleVersion value “\($0.value ?? "<not set>")” in plist file for target “\($0.targetName)” and configuration “\($0.configurationName)”" },
							previousWasSuccess: &previousWasSuccess,
							isLast: isLast
						)
						
					case .cfBundleShortVersionStringInPlistButGeneratesPlist:
						return descriptionForMessages(
							ofType: c,
							checkDescription: "CFBundleShortVersionString value check (plist)",
							failureExplanation: """
								The CFBundleShortVersionString value should be unset as your build settings defines that Xcode should generate the Info.plist file.
								The actual version should be set using the MARKETING_VERSION key in the build settings (either directly in the project or using an xcconfig file).
								""",
							failureToStringHandler: { "Unexpected CFBundleShortVersionString value “\($0.value ?? "<not set>")” in plist file for target “\($0.targetName)” and configuration “\($0.configurationName)”" },
							previousWasSuccess: &previousWasSuccess,
							isLast: isLast
						)
						
					case .buildVersionNotSet:
						return descriptionForMessages(
							ofType: c,
							checkDescription: "CURRENT_PROJECT_VERSION is set on targets",
							failureExplanation: "The CURRENT_PROJECT_VERSION must be set on all targets. It represents the current build version of the project and should be incremented at least at each release (alpha, beta, prod).",
							failureToStringHandler: { "CURRENT_PROJECT_VERSION is not set for target “\($0.targetName)” and configuration “\($0.configurationName)”" },
							previousWasSuccess: &previousWasSuccess,
							isLast: isLast
						)
						
					case .marketingVersionNotSet:
						return descriptionForMessages(
							ofType: c,
							checkDescription: "MARKETING_VERSION is set on targets",
							failureExplanation: """
								The MARKETING_VERSION must be set on all targets. It represents the marketing version of the project.
								It usually is a semver-like version number. This value should be determined by the marketing team of your project.
								""",
							failureToStringHandler: { "MARKETING_VERSION is not set for target “\($0.targetName)” and configuration “\($0.configurationName)”" },
							previousWasSuccess: &previousWasSuccess,
							isLast: isLast
						)
						
					case .buildVersionSetInXCConfigFile:
						return descriptionForMessages(
							ofType: c,
							checkDescription: "CURRENT_PROJECT_VERSION is not set in an xcconfig file",
							failureExplanation: "Setting the CURRENT_PROJECT_VERSION setting in an xcconfig file can lead to non-easily reuable xcconfig files and should be avoided.",
							failureToStringHandler: { "CURRENT_PROJECT_VERSION is set in xcconfig file \($0.value ?? "<unknown>") for target “\($0.targetName)” and configuration “\($0.configurationName)”" },
							previousWasSuccess: &previousWasSuccess,
							isLast: isLast
						)
						
					case .marketingVersionSetInXCConfigFile:
						return descriptionForMessages(
							ofType: c,
							checkDescription: "MARKETING_VERSION is not set in an xcconfig file",
							failureExplanation: "Setting the MARKETING_VERSION setting in an xcconfig file can lead to non-easily reuable xcconfig files and should be avoided.",
							failureToStringHandler: { "MARKETING_VERSION is set in xcconfig file \($0.value ?? "<unknown>") for target “\($0.targetName)” and configuration “\($0.configurationName)”" },
							previousWasSuccess: &previousWasSuccess,
							isLast: isLast
						)
						
					case .buildVersionHasMultipleSources:
						return descriptionForMessages(
							ofType: c,
							checkDescription: "CURRENT_PROJECT_VERSION is not set using variables",
							failureExplanation: "Using variables for CURRENT_PROJECT_VERSION is not recommended as it can lead to less readable settings in Xcode.",
							failureToStringHandler: { "CURRENT_PROJECT_VERSION is set using at least one variable for target “\($0.targetName)” and configuration “\($0.configurationName)”" },
							previousWasSuccess: &previousWasSuccess,
							isLast: isLast
						)
						
					case .marketingVersionHasMultipleSources:
						return descriptionForMessages(
							ofType: c,
							checkDescription: "MARKETING_VERSION is not set using variables",
							failureExplanation: "Using variables for MARKETING_VERSION is not recommended as it can lead to less readable settings in Xcode.",
							failureToStringHandler: { "MARKETING_VERSION is set using at least one variable for target “\($0.targetName)” and configuration “\($0.configurationName)”" },
							previousWasSuccess: &previousWasSuccess,
							isLast: isLast
						)
						
					case .buildVersionSetOnMultipleLevels:
						return descriptionForMessages(
							ofType: c,
							checkDescription: "CURRENT_PROJECT_VERSION is not set at more than one place",
							failureExplanation: "To ease project maintenance, CURRENT_PROJECT_VERSION should only be set once, in the build settings of the target.",
							failureToStringHandler: { "CURRENT_PROJECT_VERSION set in at least two locations for target “\($0.targetName)” and configuration “\($0.configurationName)”" },
							previousWasSuccess: &previousWasSuccess,
							isLast: isLast
						)
						
					case .marketingVersionSetOnMultipleLevels:
						return descriptionForMessages(
							ofType: c,
							checkDescription: "MARKETING_VERSION is not set at more than one place",
							failureExplanation: "To ease project maintenance, MARKETING_VERSION should only be set once, in the build settings of the target.",
							failureToStringHandler: { "MARKETING_VERSION set in at least two locations for target “\($0.targetName)” and configuration “\($0.configurationName)”" },
							previousWasSuccess: &previousWasSuccess,
							isLast: isLast
						)
				}
			}.joined()
		}
		
		init(messages m: [DiagnosticMessage]) {
			messages = m.sorted{ m1, m2 in
				if m1.messageType.rawValue < m2.messageType.rawValue {return true}
				if m1.messageType.rawValue > m2.messageType.rawValue {return false}
				
				if m1.targetName < m2.targetName {return true}
				if m1.targetName > m2.targetName {return false}
				
				if m1.configurationName < m2.configurationName {return true}
				if m1.configurationName > m2.configurationName {return false}
				
				return true
			}
		}
		
		private func descriptionForMessages(
			ofType type: DiagnosticMessage.MessageType,
			checkDescription: String,
			failureExplanation: String,
			failureToStringHandler: (DiagnosticMessage) -> String,
			previousWasSuccess: inout Bool,
			isLast: Bool
		) -> String {
			let filteredMessages = messages.filter{ $0.messageType == type }
			let isFailure = !filteredMessages.isEmpty
			let emoji = (!isFailure ? "✅" : "❌")
			let descriptionBase = filteredMessages.reduce("\(checkDescription): \(emoji)\n" + (isFailure ? failureExplanation + "\n" : ""), { result, diagnostic in
				result + "   - " + failureToStringHandler(diagnostic) + "\n"
			})
			
			let previousWasSuccessLocal = previousWasSuccess
			previousWasSuccess = !isFailure
			
			return (previousWasSuccessLocal && isFailure ? "\n" : "") + descriptionBase + (isFailure && !isLast ? "\n" : "")
		}
		
	}
	
}
