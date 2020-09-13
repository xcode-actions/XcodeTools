import CoreData
import Foundation



@objc(XCVersionGroup)
public class XCVersionGroup : PBXFileElement {
	
	public override class func propertyRenamings() -> [String : String] {
		let mine = [
			"children_cd": "children"
		]
		return super.propertyRenamings().merging(mine, uniquingKeysWith: { current, new in
			precondition(current == new, "Incompatible property renamings")
			NSLog("%@", "Warning: Internal logic shadiness: Property rename has been declared twice for destination \(current), in class \(self)")
			return current
		})
	}
	
	open override func fillValues(rawObject: [String : Any], rawObjects: [String : [String : Any]], context: NSManagedObjectContext, decodedObjects: inout [String : PBXObject]) throws {
		try super.fillValues(rawObject: rawObject, rawObjects: rawObjects, context: context, decodedObjects: &decodedObjects)
		
		versionGroupType = try rawObject.get("versionGroupType")
		
		let currentVersionID: String = try rawObject.get("currentVersion")
		currentVersion = try PBXFileReference.unsafeInstantiate(rawObjects: rawObjects, id: currentVersionID, context: context, decodedObjects: &decodedObjects)
		
		let childrenIDs: [String] = try rawObject.get("children")
		children = try childrenIDs.map{ try PBXFileReference.unsafeInstantiate(rawObjects: rawObjects, id: $0, context: context, decodedObjects: &decodedObjects) }
	}
	
	public var children: [PBXFileReference]? {
		get {children_cd?.array as! [PBXFileReference]?}
		set {children_cd = newValue.flatMap{ NSOrderedSet(array: $0) }}
	}
	
}