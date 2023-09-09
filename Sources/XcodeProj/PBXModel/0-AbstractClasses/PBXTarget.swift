import CoreData
import Foundation



@objc(PBXTarget)
public class PBXTarget : PBXObject {
	
	open override class func propertyRenamings() -> [String : String] {
		return super.propertyRenamings().mergingUnambiguous([
			"buildPhases_cd": "buildPhases",
			"dependencies_cd": "dependencies"
		])
	}
	
	open override func fillValues(rawObject: [String : Any], rawObjects: [String : [String : Any]], context: NSManagedObjectContext, decodedObjects: inout [String : PBXObject]) throws {
		try super.fillValues(rawObject: rawObject, rawObjects: rawObjects, context: context, decodedObjects: &decodedObjects)
		
		name = try rawObject.getForParse("name", xcID)
		productName = try rawObject.getForParse("productName", xcID)
		
		let dependenciesIDs: [String] = try rawObject.getForParse("dependencies", xcID)
		dependencies = try dependenciesIDs.map{ try PBXTargetDependency.unsafeInstantiate(id: $0, on: context, rawObjects: rawObjects, decodedObjects: &decodedObjects) }
		
		let buildPhasesIDs: [String] = try rawObject.getForParse("buildPhases", xcID)
		buildPhases = try buildPhasesIDs.map{ try PBXBuildPhase.unsafeInstantiate(id: $0, on: context, rawObjects: rawObjects, decodedObjects: &decodedObjects) }
		
		let buildConfigurationListID: String = try rawObject.getForParse("buildConfigurationList", xcID)
		buildConfigurationList = try XCConfigurationList.unsafeInstantiate(id: buildConfigurationListID, on: context, rawObjects: rawObjects, decodedObjects: &decodedObjects)
	}
	
	public var buildPhases: [PBXBuildPhase]? {
		get {buildPhases_cd?.array as! [PBXBuildPhase]?}
		set {buildPhases_cd = newValue.flatMap{ NSOrderedSet(array: $0) }}
	}
	
	public var dependencies: [PBXTargetDependency]? {
		get {dependencies_cd?.array as! [PBXTargetDependency]?}
		set {dependencies_cd = newValue.flatMap{ NSOrderedSet(array: $0) }}
	}
	
	public override func stringSerializationName(projectName: String) -> String? {
		return name
	}
	
	open override func knownValuesSerialized(projectName: String) throws -> [String: Any] {
		var mySerialization = [String: Any]()
		mySerialization["name"]                   = try getName()
		mySerialization["productName"]            = try getProductName()
		mySerialization["dependencies"]           = try getDependencies().getIDsAndCommentsForSerialization("dependencies", xcID, projectName: projectName)
		mySerialization["buildPhases"]            = try getBuildPhases().getIDsAndCommentsForSerialization("buildPhases", xcID, projectName: projectName)
		mySerialization["buildConfigurationList"] = try getBuildConfigurationList().getIDAndCommentForSerialization("buildConfigurationList", xcID, projectName: projectName)
		
		return try mergeSerialization(super.knownValuesSerialized(projectName: projectName), mySerialization)
	}
	
	public func getName()                   throws -> String                {try PBXObject.getNonOptionalValue(name,                   "name",                   xcID)}
	public func getProject()                throws -> PBXProject            {try PBXObject.getNonOptionalValue(i_project,              "i_project",              xcID)}
	public func getProductName()            throws -> String                {try PBXObject.getNonOptionalValue(productName,            "productName",            xcID)}
	public func getBuildPhases()            throws -> [PBXBuildPhase]       {try PBXObject.getNonOptionalValue(buildPhases,            "buildPhases",            xcID)}
	public func getDependencies()           throws -> [PBXTargetDependency] {try PBXObject.getNonOptionalValue(dependencies,           "dependencies",           xcID)}
	public func getBuildConfigurationList() throws -> XCConfigurationList   {try PBXObject.getNonOptionalValue(buildConfigurationList, "buildConfigurationList", xcID)}
	
	public func getBuildConfigurations() throws -> [XCBuildConfiguration] {
		return try getBuildConfigurationList().getBuildConfigurations()
	}
	
}
