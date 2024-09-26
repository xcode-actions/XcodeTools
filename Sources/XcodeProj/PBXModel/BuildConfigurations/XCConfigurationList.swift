import CoreData
import Foundation

import GlobalConfModule



@objc(XCConfigurationList)
public class XCConfigurationList : PBXObject {
	
	open override class func propertyRenamings() -> [String : String] {
		return super.propertyRenamings().mergingUnambiguous([
			"buildConfigurations_cd": "buildConfigurations"
		])
	}
	
	open override func fillValues(rawObject: [String : Any], rawObjects: [String : [String : Any]], context: NSManagedObjectContext, decodedObjects: inout [String : PBXObject]) throws {
		try super.fillValues(rawObject: rawObject, rawObjects: rawObjects, context: context, decodedObjects: &decodedObjects)
		
		defaultConfigurationName = try rawObject.getIfExistsForParse("defaultConfigurationName", xcID)
		
		/* No idea what defaultConfigurationIsVisible changes, but it exists… */
		defaultConfigurationIsVisible = try rawObject.getBoolForParse("defaultConfigurationIsVisible", xcID)
		
		let buildConfigurationIDs: [String] = try rawObject.getForParse("buildConfigurations", xcID)
		buildConfigurations = try buildConfigurationIDs.map{ try XCBuildConfiguration.unsafeInstantiate(id: $0, on: context, rawObjects: rawObjects, decodedObjects: &decodedObjects) }
	}
	
	public var buildConfigurations: [XCBuildConfiguration]? {
		get {buildConfigurations_cd?.array as! [XCBuildConfiguration]?}
		set {buildConfigurations_cd = newValue.flatMap{ NSOrderedSet(array: $0) }}
	}
	
	open override func stringSerializationName(projectName: String) -> String? {
		let usedByType: String
		let usedByName: String
		if let p = i_project {
			usedByType = p.rawISA ?? "(null)"
			usedByName = projectName
		} else if let t = i_target {
			usedByType = t.rawISA ?? "(null)"
			usedByName = t.name ?? "(null)"
		} else {
			Conf.logger?.warning("Cannot get stringSerializationName for configuration list \(xcID ?? "<nil>") because both the project and target relationships are nil.")
			return nil
		}
		return "Build configuration list for \(usedByType) \"\(usedByName)\""
	}
	
	open override func knownValuesSerialized(projectName: String) throws -> [String: Any] {
		var mySerialization = [String: Any]()
		if let n = defaultConfigurationName {mySerialization["defaultConfigurationName"] = n}
		mySerialization["defaultConfigurationIsVisible"] = defaultConfigurationIsVisible ? "1" : "0"
		mySerialization["buildConfigurations"]           = try getBuildConfigurations().getIDsAndCommentsForSerialization("buildConfigurations", xcID, projectName: projectName)
		
		return try mergeSerialization(super.knownValuesSerialized(projectName: projectName), mySerialization)
	}
	
	public func getBuildConfigurations() throws -> [XCBuildConfiguration] {try PBXObject.getNonOptionalValue(buildConfigurations, "buildConfigurations", xcID)}
	
}
