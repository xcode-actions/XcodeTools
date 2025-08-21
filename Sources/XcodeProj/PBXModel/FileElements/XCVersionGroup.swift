import CoreData
import Foundation



@objc(XCVersionGroup)
public class XCVersionGroup : PBXFileElement {
	
	open override class func propertyRenamings() -> [String : String] {
		return super.propertyRenamings().mergingUnambiguous([
			"children_cd": "children"
		])
	}
	
	open override func fillValues(rawObject: [String : Any], rawObjects: [String : [String : Any]], context: NSManagedObjectContext, decodedObjects: inout [String : PBXObject]) throws {
		try super.fillValues(rawObject: rawObject, rawObjects: rawObjects, context: context, decodedObjects: &decodedObjects)
		
		versionGroupType = try rawObject.getForParse("versionGroupType", xcID)
		
		let currentVersionID: String = try rawObject.getForParse("currentVersion", xcID)
		currentVersion = try PBXFileReference.onContext_instantiate(id: currentVersionID, on: context, rawObjects: rawObjects, decodedObjects: &decodedObjects)
		
		let childrenIDs: [String] = try rawObject.getForParse("children", xcID)
		children = try childrenIDs.map{ try PBXFileReference.onContext_instantiate(id: $0, on: context, rawObjects: rawObjects, decodedObjects: &decodedObjects) }
	}
	
	public var children: [PBXFileReference]? {
		get {children_cd?.array as! [PBXFileReference]?}
		set {children_cd = newValue.flatMap{ NSOrderedSet(array: $0) }}
	}
	
	open override func knownValuesSerialized(projectName: String) throws -> [String: Any] {
		var mySerialization = [String: Any]()
		mySerialization["versionGroupType"] = try getVersionGroupType()
		mySerialization["currentVersion"] = try getCurrentVersion().getIDAndCommentForSerialization("currentVersion", xcID, projectName: projectName)
		mySerialization["children"] = try getChildren().getIDsAndCommentsForSerialization("children", xcID, projectName: projectName)
		
		return try mergeSerialization(super.knownValuesSerialized(projectName: projectName), mySerialization)
	}
	
	public func getVersionGroupType() throws -> String             {try PBXObject.getNonOptionalValue(versionGroupType, "versionGroupType", xcID)}
	public func getChildren()         throws -> [PBXFileReference] {try PBXObject.getNonOptionalValue(children,         "children",         xcID)}
	public func getCurrentVersion()   throws -> PBXFileReference   {try PBXObject.getNonOptionalValue(currentVersion,   "currentVersion",   xcID)}
	
}
