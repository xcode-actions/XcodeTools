import CoreData
import Foundation



@objc(PBXGroup)
public class PBXGroup : PBXFileElement {
	
	open override class func propertyRenamings() -> [String : String] {
		return super.propertyRenamings().mergingUnambiguous([
			"children_cd": "children"
		])
	}
	
	open override func fillValues(rawObject: [String : Any], rawObjects: [String : [String : Any]], context: NSManagedObjectContext, decodedObjects: inout [String : PBXObject]) throws {
		try super.fillValues(rawObject: rawObject, rawObjects: rawObjects, context: context, decodedObjects: &decodedObjects)
		
		let childrenIDs: [String] = try rawObject.getForParse("children", xcID)
		children = try childrenIDs.map{ try PBXFileElement.onContext_instantiate(id: $0, on: context, rawObjects: rawObjects, decodedObjects: &decodedObjects) }
	}
	
	public var children: [PBXFileElement]? {
		get {PBXObject.getOptionalToMany(children_cd, children_isSet)}
		set {(children_cd, children_isSet) = PBXObject.setOptionalToManyTuple(newValue)}
	}
	
	open override func knownValuesSerialized(projectName: String) throws -> [String: Any] {
		var mySerialization = [String: Any]()
		mySerialization["children"] = try getChildren().getIDsAndCommentsForSerialization("children", xcID, projectName: projectName)
		
		return try mergeSerialization(super.knownValuesSerialized(projectName: projectName), mySerialization)
	}
	
	public func getChildren() throws -> [PBXFileElement] {try PBXObject.getNonOptionalValue(children, "children", xcID)}
	
}
