import CoreData
import Foundation



/* From <http://www.monobjc.net/xcode-project-file-format.html>. */
@objc(PBXAppleScriptBuildPhase)
public class PBXAppleScriptBuildPhase : PBXBuildPhase {
	
	open override func fillValues(rawObject: [String : Any], rawObjects: [String : [String : Any]], context: NSManagedObjectContext, decodedObjects: inout [String : PBXObject]) throws {
		try super.fillValues(rawObject: rawObject, rawObjects: rawObjects, context: context, decodedObjects: &decodedObjects)
	}
	
	open override var buildPhaseBaseTypeAsString: String {
		return "AppleScript" /* I guess… */
	}
	
}
