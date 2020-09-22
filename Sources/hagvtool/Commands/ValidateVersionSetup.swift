import Foundation

import ArgumentParser
import XcodeProjKit



struct ValidateVersionSetup : ParsableCommand {
	
	@OptionGroup
	var hagvtoolOptions: Hagvtool.Options
	
	func run() throws {
		let xcodeproj = try XcodeProj(path: hagvtoolOptions.pathToXcodeproj, autodetectInFolderAtPath: ".")
		let xcodeprojURL = xcodeproj.xcodeprojURL
		
		let messages = try xcodeproj.iterateCombinedBuildSettingsOfTargets(matchingOptions: hagvtoolOptions){ target, targetName, configurationName, combinedBuildSettings -> [Output.DiagnosticMessage] in
			let plistMessages: [Output.DiagnosticMessage?]
			if let plist = try combinedBuildSettings.infoPlistRaw(xcodeprojURL: xcodeprojURL) {
				let bundleVersion = plist["CFBundleVersion"] as? String
				let bundleVersionMessage = Output.DiagnosticMessage(messageType: .invalidCFBundleVersionInPlist, value: bundleVersion, targetName: targetName, configurationName: configurationName)
				
				let shortVersionString = plist["CFBundleShortVersionString"] as? String
				let shortVersionStringMessage = Output.DiagnosticMessage(messageType: .invalidCFBundleShortVersionStringInPlist, value: shortVersionString, targetName: targetName, configurationName: configurationName)
				
				plistMessages = [
					(bundleVersion      != "$(CURRENT_PROJECT_VERSION)" ? bundleVersionMessage      : nil),
					(shortVersionString != "$(MARKETING_VERSION)"       ? shortVersionStringMessage : nil)
				]
			} else {
				plistMessages = []
			}
			
			let versioningSystem = combinedBuildSettings[BuildSettingKey(key: "VERSIONING_SYSTEM")]
			let versioningSystemMessage = Output.DiagnosticMessage(messageType: .invalidVersioningSystem, value: versioningSystem, targetName: targetName, configurationName: configurationName)
			
			let nonPlistMessages = [
				(versioningSystem != "apple-generic" ? versioningSystemMessage : nil)
			]
			
			return (nonPlistMessages + plistMessages).compactMap{ $0 }
		}.flatMap{ $0 }
		
		let output = Output(messages: messages)
		try Hagvtool.printOutput(output, format: hagvtoolOptions.outputFormat)
		
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
			
			enum MessageType : String, Encodable {
				
				case invalidVersioningSystem = "invalid-versioning-system"
				case invalidCFBundleVersionInPlist = "invalid-CFBundleVersion-in-plist"
				case invalidCFBundleShortVersionStringInPlist = "invalid-CFBundleShortVersionString-in-plist"
				
			}
			
			var messageType: MessageType
			var value: String?
			
			var targetName: String
			var configurationName: String
			
		}
		
		var messages: [DiagnosticMessage]
		
		var description: String {
//			print("*** Verifying versioning system")
//			print("   -> Unexpected versioning system “\(versioningSystem)” for target “\(targetName)” and configuration “\(configurationName)”")
//			if ok {
//				print("-> OK")
//			} else {
//				print("-> FAIL")
//				print("The versioning system should be set to “apple-generic” for all targets, though in practice not setting this build setting will not change much.")
//			}
//
//			print("*** Verifying sanity of current project version and marketing version in Info.plist")
//			print("   -> Unexpected CFBundleVersion value “\(versionString ?? "<no value>")” in plist file for target “\(targetName)” and configuration “\(configurationName)”")
//			print("   -> Unexpected CFBundleShortVersionString value “\(shortVersionString ?? "<no value>")” in plist file for target “\(targetName)” and configuration “\(configurationName)”")
//			if ok {
//				print("-> OK")
//			} else {
//				print("-> FAIL")
//				print("The CFBundleVersion value should be set to “$(CURRENT_PROJECT_VERSION)” and the CFBundleShortVersionString should be set to “$(MARKETING_VERSION)”.")
//				print("Of course, the actual versions should be set in the build settings (either directly in the project or using an xcconfig file).")
//			}
			return ""
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
		
	}
	
}
