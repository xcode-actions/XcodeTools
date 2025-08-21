import CoreData
import Foundation



@objc(PBXBuildPhase)
public class PBXBuildPhase : PBXObject {
	
	open override class func propertyRenamings() -> [String : String] {
		return super.propertyRenamings().mergingUnambiguous([
			"files_cd": "files"
		])
	}
	
	open override func fillValues(rawObject: [String : Any], rawObjects: [String : [String : Any]], context: NSManagedObjectContext, decodedObjects: inout [String : PBXObject]) throws {
		try super.fillValues(rawObject: rawObject, rawObjects: rawObjects, context: context, decodedObjects: &decodedObjects)
		
		name = try rawObject.getIfExistsForParse("name", xcID)
		
		let filesIDs: [String] = try rawObject.getForParse("files", xcID)
		files = try filesIDs.map{ try PBXBuildFile.onContext_instantiate(id: $0, on: context, rawObjects: rawObjects, decodedObjects: &decodedObjects) }
		
		buildActionMask = try rawObject.getInt32AsNumberIfExistsForParse("buildActionMask", xcID)
		runOnlyForDeploymentPostprocessing = try rawObject.getBoolAsNumberIfExistsForParse("runOnlyForDeploymentPostprocessing", xcID)
	}
	
	public var files: [PBXBuildFile]? {
		get {files_cd?.array as! [PBXBuildFile]?}
		set {files_cd = newValue.flatMap{ NSOrderedSet(array: $0) }}
	}
	
	public override func stringSerializationName(projectName: String) -> String? {
		return name ?? buildPhaseBaseTypeAsString
	}
	
	open var buildPhaseBaseTypeAsString: String {
		return "<Invalid, buildPhaseTypeAsString is abstract and should be overridden>"
	}
	
	open override func knownValuesSerialized(projectName: String) throws -> [String: Any] {
		var mySerialization = [String: Any]()
		if let n = name                                          {mySerialization["name"] = n}
		if let m = buildActionMask                               {mySerialization["buildActionMask"] = m.stringValue}
		if let b = runOnlyForDeploymentPostprocessing?.boolValue {mySerialization["runOnlyForDeploymentPostprocessing"] = b ? "1" : "0"}
		mySerialization["files"] = try getFiles().getIDsAndCommentsForSerialization("files", xcID, projectName: projectName)
		
		return try mergeSerialization(super.knownValuesSerialized(projectName: projectName), mySerialization)
	}
	
	public func getFiles() throws -> [PBXBuildFile] {try PBXObject.getNonOptionalValue(files, "files", xcID)}
	
}
