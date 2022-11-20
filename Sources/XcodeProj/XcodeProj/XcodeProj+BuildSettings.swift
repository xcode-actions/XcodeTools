import CoreData
import Foundation

import Utils



extension XcodeProj {
	
	@discardableResult
	public func iterateCombinedBuildSettingsOfProject<T>(_ handler: (_ configuration: XCBuildConfiguration, _ configurationName: String, _ combinedBuildSettings: CombinedBuildSettings) throws -> T) throws -> [T] {
		let defaultBuildSettings = try BuildSettings.standardDefaultSettings(xcodprojURL: xcodeprojURL)
		return try iterateCombinedBuildSettingsOfProject(defaultBuildSettings: BuildSettingsRef(defaultBuildSettings), handler)
	}
	
	@discardableResult
	public func iterateCombinedBuildSettingsOfTargets<T>(_ handler: (_ target: PBXTarget, _ targetName: String, _ configuration: XCBuildConfiguration, _ configurationName: String, _ combinedBuildSettings: CombinedBuildSettings) throws -> T) throws -> [T] {
		let defaultBuildSettings = try BuildSettings.standardDefaultSettings(xcodprojURL: xcodeprojURL)
		return try iterateCombinedBuildSettingsOfTargets(defaultBuildSettings: BuildSettingsRef(defaultBuildSettings), handler)
	}
	
	@discardableResult
	public func iterateCombinedBuildSettingsOfProject<T>(defaultBuildSettings: BuildSettingsRef, _ handler: (_ configuration: XCBuildConfiguration, _ configurationName: String, _ combinedBuildSettings: CombinedBuildSettings) throws -> T) throws -> [T] {
		return try managedObjectContext.performAndWait{
			let pbxProject = pbxproj.rootObject
			let allCombinedBuildSettings = try CombinedBuildSettings.allCombinedBuildSettingsForProject(pbxProject, xcodeprojURL: xcodeprojURL, defaultBuildSettings: defaultBuildSettings)
			
			return try allCombinedBuildSettings.sorted(by: CombinedBuildSettings.convenienceSort).map{ combinedBuildSettings -> T in
				guard combinedBuildSettings.targetName == nil else {
					throw Err.internalError(.combinedSettingsForProjectWithTargetName)
				}
				return try handler(combinedBuildSettings.configuration, combinedBuildSettings.configurationName, combinedBuildSettings)
			}
		}
	}
	
	@discardableResult
	public func iterateCombinedBuildSettingsOfTargets<T>(defaultBuildSettings: BuildSettingsRef, _ handler: (_ target: PBXTarget, _ targetName: String, _ configuration: XCBuildConfiguration, _ configurationName: String, _ combinedBuildSettings: CombinedBuildSettings) throws -> T) throws -> [T] {
		return try managedObjectContext.performAndWait{
			let pbxProject = pbxproj.rootObject
			let allCombinedBuildSettings = try CombinedBuildSettings.allCombinedBuildSettingsForTargets(of: pbxProject, xcodeprojURL: xcodeprojURL, defaultBuildSettings: defaultBuildSettings)
			
			return try allCombinedBuildSettings.sorted(by: CombinedBuildSettings.convenienceSort).map{ combinedBuildSettings -> T in
				guard let targetName = combinedBuildSettings.targetName else {
					throw Err.internalError(.combinedSettingsForTargetWithoutTargetName)
				}
				guard let target = combinedBuildSettings.target else {
					throw Err.internalError(.combinedSettingsForTargetWithoutTarget)
				}
				return try handler(target, targetName, combinedBuildSettings.configuration, combinedBuildSettings.configurationName, combinedBuildSettings)
			}
		}
	}
	
}
