import CoreData
import Foundation



@objc(PBXFrameworksBuildPhase)
public class PBXFrameworksBuildPhase : PBXBuildPhase {
	
	open override func fillValues(rawObject: [String : Any], rawObjects: [String : [String : Any]], context: NSManagedObjectContext, decodedObjects: inout [String : PBXObject]) throws {
		try super.fillValues(rawObject: rawObject, rawObjects: rawObjects, context: context, decodedObjects: &decodedObjects)
	}
	
	open override var buildPhaseBaseTypeAsString: String {
		return "Frameworks" /* I guess… */
	}
	
}
