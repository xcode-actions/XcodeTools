import CoreData
import Foundation



/** Represents a file to build in a build phase.
 
 It’s basically a reference to a ``PBXFileElement`` with some settings. */
@objc(PBXBuildFile)
public class PBXBuildFile : PBXObject {
	
	open override class func propertyRenamings() -> [String : String] {
		return super.propertyRenamings().mergingUnambiguous([
			"rawSettings": "settings"
		])
	}
	
	open override func fillValues(rawObject: [String : Any], rawObjects: [String : [String : Any]], context: NSManagedObjectContext, decodedObjects: inout [String : PBXObject]) throws {
		try super.fillValues(rawObject: rawObject, rawObjects: rawObjects, context: context, decodedObjects: &decodedObjects)
		
		rawSettings = try rawObject.getIfExistsForParse("settings", xcID)
		
		let fileRefID: String? = try rawObject.getIfExistsForParse("fileRef", xcID)
		fileRef = try fileRefID.flatMap{ try PBXFileElement.unsafeInstantiate(id: $0, on: context, rawObjects: rawObjects, decodedObjects: &decodedObjects) }
		
		let productRefID: String? = try rawObject.getIfExistsForParse("productRef", xcID)
		productRef = try productRefID.flatMap{ try XCSwiftPackageProductDependency.unsafeInstantiate(id: $0, on: context, rawObjects: rawObjects, decodedObjects: &decodedObjects) }
	}
	
	open override var oneLineStringSerialization: Bool {
		return true
	}
	
	open override func stringSerializationName(projectName: String) -> String? {
		let fileName = itemName ?? "(null)"
		let buildPhaseName = i_buildPhase?.stringSerializationName(projectName: projectName) ?? "(null)"
		return fileName + " in " + buildPhaseName
	}
	
	open override func knownValuesSerialized(projectName: String) throws -> [String: Any] {
		var mySerialization = [String: Any]()
		if let s = rawSettings {mySerialization["settings"]   = s}
		if let r = fileRef     {mySerialization["fileRef"]    = try r.getIDAndCommentForSerialization("fileRef", xcID, projectName: projectName)}
		if let r = productRef  {mySerialization["productRef"] = try r.getIDAndCommentForSerialization("productRef", xcID, projectName: projectName)}
		
		return try mergeSerialization(super.knownValuesSerialized(projectName: projectName), mySerialization)
	}
	
	public var itemName: String? {
		return fileRef?.name ?? productRef?.productName
	}
	
}
