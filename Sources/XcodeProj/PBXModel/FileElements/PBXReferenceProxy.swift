import CoreData
import Foundation



@objc(PBXReferenceProxy)
public class PBXReferenceProxy : PBXFileElement {
	
	open override func fillValues(rawObject: [String : Any], rawObjects: [String : [String : Any]], context: NSManagedObjectContext, decodedObjects: inout [String : PBXObject]) throws {
		try super.fillValues(rawObject: rawObject, rawObjects: rawObjects, context: context, decodedObjects: &decodedObjects)
		
		fileType = try rawObject.getForParse("fileType", xcID)
		
		let remoteRefID: String = try rawObject.getForParse("remoteRef", xcID)
		remoteRef = try PBXContainerItemProxy.onContext_instantiate(id: remoteRefID, on: context, rawObjects: rawObjects, decodedObjects: &decodedObjects)
	}
	
	open override func knownValuesSerialized(projectName: String) throws -> [String: Any] {
		var mySerialization = [String: Any]()
		mySerialization["fileType"]  = try getFileType()
		mySerialization["remoteRef"] = try getRemoteRef().getIDAndCommentForSerialization("remoteRef", xcID, projectName: projectName)
		
		return try mergeSerialization(super.knownValuesSerialized(projectName: projectName), mySerialization)
	}
	
	public func getFileType()  throws -> String                {try PBXObject.getNonOptionalValue(fileType,  "fileType",  xcID)}
	public func getRemoteRef() throws -> PBXContainerItemProxy {try PBXObject.getNonOptionalValue(remoteRef, "remoteRef", xcID)}
	
}
