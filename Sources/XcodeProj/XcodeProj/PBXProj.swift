import CoreData
import Foundation

import GlobalConfModule



/** Represents a parsed `pbxproj` file, which is the main file of an xcodeproj bundle. */
public struct PBXProj {
	
	public let rawDecoded: [String: Any]
	
	/** Should always be 1 (only version supported). */
	public let archiveVersion: String
	
	public let objectVersion: String
	
	/** The ID of the root object. */
	public let rootObjectID: String
	
	/**
	 The pbxproj file can contain a “classes” property (it usually does), which is usually empty (I have never seen a file where it’s not).
	 
	 We keep the information whether the property was present to be able to rewrite the pbxproj. */
	public let hasClassesProperty: Bool
	
	/**
	 All the objects in the project, keyed by their IDs. */
	public let rawObjects: [String: [String: Any]]
	
	public let rootObject: PBXProject
	
	public init(url: URL, context: NSManagedObjectContext) throws {
		let data = try Result{ try Data(contentsOf: url) }.mapErrorAndGet{ Err.cannotReadFile(url, $0) }
		
		var format = PropertyListSerialization.PropertyListFormat.xml
		let decodedUntyped = try Result{ try PropertyListSerialization.propertyList(from: data, options: [], format: &format) }
			.mapErrorAndGet{ Err.pbxProjParseError(.plistParseError($0), objectID: nil) }
		
		if format != .openStep {
			Conf.logger?.warning("pbxproj file was deserialized w/ plist format \(format), which is unexpected (expected OpenStep format). Serialization will probably be different than source.")
		}
		
		guard let decoded = decodedUntyped as? [String: Any] else {
			throw Err.pbxProjParseError(.deserializedPlistHasInvalidType, objectID: nil)
		}
		
		rawDecoded = decoded
		
		archiveVersion = try rawDecoded.getForParse("archiveVersion", nil)
		guard archiveVersion == "1" else {
			throw Err.unsupportedPBXProj(.unknownArchiveVersion(archiveVersion))
		}
		
		objectVersion = try rawDecoded.getForParse("objectVersion", nil)
		if !Set(arrayLiteral: "46", "48", "50", "51", "52", "53", "54", "55").contains(objectVersion) {
			let msg = "Unknown object version \(objectVersion); parsing might fail"
			Conf.logger?.warning(.init(stringLiteral: msg))
		}
		
		let classes: [String: Any]? = try rawDecoded.getIfExistsForParse("classes", nil)
		guard classes?.isEmpty ?? true else {
			throw Err.unsupportedPBXProj(.classesPropertyIsNotEmpty/*(classes!)*/)
		}
		hasClassesProperty = (classes != nil)
		
		let roid: String = try rawDecoded.getForParse("rootObject", nil)
		let ro: [String: [String: Any]] = try rawDecoded.getForParse("objects", nil)
		rootObjectID = roid
		rawObjects = ro
		
		let unknownProperties = Set(arrayLiteral: "archiveVersion", "objectVersion", "classes", "rootObject", "objects")
			.subtracting(rawDecoded.keys)
		guard unknownProperties.isEmpty else {
			throw Err.unsupportedPBXProj(.unknownRootProperties(unknownProperties))
		}
		
		rootObject = try context.performAndWait{
			var decodedObjects = [String: PBXObject]()
			for key in ro.keys {
				_ = try PBXObject.unsafeInstantiate(id: key, on: context, rawObjects: ro, decodedObjects: &decodedObjects)
			}
			let ret = try PBXProject.unsafeInstantiate(id: roid, on: context, rawObjects: ro, decodedObjects: &decodedObjects)
			do {
				try context.save()
			} catch {
				Conf.logger?.debug("Error when saving PBXProj model: \(error)")
				Conf.logger?.debug("   -> Validation errors: \(((error as NSError).userInfo["NSDetailedErrors"] as? [NSError])?.first?.userInfo["NSValidationErrorObject"] ?? "<none>")")
				context.rollback()
				throw Err.invalidPBXProjObjectGraph(.coreDataSaveError(error), objectID: nil)
			}
			return ret
		}
	}
	
	public func stringSerialization(projectName: String) throws -> String {
		/* It is a programmer error to try and serialize a PBXProj whose root object has been deleted (nil managed object context),
		 * hence the forced unwrap. */
		let context = rootObject.managedObjectContext!
		
		var ret = """
			// !$*UTF8*$!
			{
				archiveVersion = \(archiveVersion.escapedForPBXProjValue());
			"""
		if hasClassesProperty {
			ret += """
				
					classes = {
					};
				"""
		}
		ret += """
			
				objectVersion = \(objectVersion.escapedForPBXProjValue());
				objects = {
			"""
		
		try context.performAndWait{
			let request: NSFetchRequest<PBXObject> = PBXObject.fetchRequest()
			request.sortDescriptors = [
				NSSortDescriptor(keyPath: \PBXObject.rawISA, ascending: true),
				NSSortDescriptor(keyPath: \PBXObject.xcID, ascending: true)
			]
			
			var previousISA: String?
			func printEndSection() {
				if let previousISA = previousISA {
					ret += """
							
							/* End \(previousISA) section */
							"""
				}
			}
			
			for object in try context.fetch(request) {
				let isa = try object.getISA()
				if isa != previousISA {
					printEndSection()
					ret += """
						
						
						/* Begin \(isa) section */
						"""
				}
				previousISA = isa
				ret += try object.stringSerialization(projectName: projectName, indentCount: 2)
			}
			printEndSection()
		}
		
		let idAndComment = try rootObject.getIDAndCommentForSerialization("xcID", rootObject.xcID, projectName: projectName).asString()
		ret += """
			
				};
				rootObject = \(idAndComment);
			}
			
			"""
		
		return ret
	}
	
}
