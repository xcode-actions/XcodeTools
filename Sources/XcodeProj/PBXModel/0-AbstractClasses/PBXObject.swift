import CoreData
import Foundation



/* Sadly we cannot implement fillValues in an extension because overriding method in extensions is not supported. */
@objc(PBXObject)
public class PBXObject : NSManagedObject {
	
	/* **************
	   MARK: - Public
	   ************** */
	
	open class func propertyRenamings() -> [String: String] {
		return ["xcID": "id"]
	}
	
	open var oneLineStringSerialization: Bool {
		return false
	}
	
	open func stringSerializationName(projectName: String) -> String? {
		return nil
	}
	
	open func knownValuesSerialized(projectName: String) throws -> [String: Any] {
		return try ["isa": getISA()]
	}
	
	public func getISA()     throws -> String {try PBXObject.getNonOptionalValue(rawISA, "isa",     xcID)}
	public func getXcodeID() throws -> String {try PBXObject.getNonOptionalValue(xcID,   "XcodeID", xcID)}
	
	/**
	 All the values in the raw object, but modified w/ known values in the model. */
	public func allSerialized(projectName: String) throws -> [String: Any] {
		let known = try knownValuesSerialized(projectName: projectName)
		let nonNilRawObject = rawObject ?? [:]
		
		let diffUnknownButExist = Set(nonNilRawObject.keys).subtracting(known.keys)
		let diffKnownButDoNotExist = Set(known.keys).subtracting(nonNilRawObject.keys)
		if !diffUnknownButExist.isEmpty,    let logger = Conf.logger {logger.warning("In object \(xcID ?? "<unknown>") of type \(rawISA ?? "<unknown>"), got the following keys that are unknown by the object but exist in the raw object: \(diffUnknownButExist.sorted())")}
		if !diffKnownButDoNotExist.isEmpty, let logger = Conf.logger {logger.warning("In object \(xcID ?? "<unknown>") of type \(rawISA ?? "<unknown>"), got the following keys that are known by the object but do **not** exist in the raw object: \(diffKnownButDoNotExist)")}
		
		return (rawObject ?? [:]).merging(known, uniquingKeysWith: { _, new in new })
	}
	
	/* Sadly, we do need the project name here… */
	public func stringSerialization(projectName: String, indentCount: Int = 0, indentBase: String = "\t") throws -> String {
		let indent = String(repeating: indentBase, count: indentCount)
		
		let key = try """
		
		\(indent)\(PBXObject.getNonOptionalValue(xcIDAndCommentString(projectName: projectName), "xcID", xcID))
		"""
		let value = try serializeAnyToString(allSerialized(projectName: projectName), isRoot: true, projectName: projectName, indentCount: indentCount, indentBase: indentBase, oneline: oneLineStringSerialization)
		return key + " = " + value + ";"
		
	}
	
	/* ****************
	   MARK: - Internal
	   **************** */
	
	/**
	 Instantiate a managed object if needed, or return the already instantiated object from the `decodedObjects` dictionary.
	 In case of instantiation, will add the instantiated object to the `decodedObjects` dictionary. */
	static func unsafeInstantiate(id: String, on context: NSManagedObjectContext, rawObjects: [String: [String: Any]], decodedObjects: inout [String: PBXObject]) throws -> Self {
		if let decodedObject = decodedObjects[id] {
			guard let result = decodedObject as? Self else {
				throw Err.pbxProjParseError(.invalidObjectTypeInDecodedObjects(expectedType: self), objectID: id)
			}
			return result
		}
		
		let rawObject: [String: Any] = try rawObjects.getForParse(id, nil)
		let isa: String = try rawObject.getForParse("isa", id)
		
		guard let model = context.persistentStoreCoordinator?.managedObjectModel else {
			throw Err.internalError(.managedContextHasNoModel)
		}
		guard let entity = model.entitiesByName[isa] ?? (Conf.allowPBXObjectAllocation ? model.entitiesByName["PBXObject"] : nil) else {
			throw Err.pbxProjParseError(.isaNotFoundInModel(isa), objectID: id)
		}
		guard !entity.isAbstract || (Conf.allowPBXObjectAllocation && entity.name == "PBXObject") else {
			throw Err.pbxProjParseError(.tryingToInstantiateAbstractISA(isa, entity: entity), objectID: id)
		}
		guard entity.topmostSuperentity().name == "PBXObject" else {
			throw Err.internalError(.tryingToInstantiateNonPBXObjectEntity(isa: isa, entity: entity))
		}
		
		/* First let’s see if the object is not already in the graph */
		let fetchRequest = NSFetchRequest<PBXObject>()
		fetchRequest.entity = entity
		fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(PBXObject.xcID), id)
		let results = try context.fetch(fetchRequest)
		guard results.count <= 1 else {
			throw Err.internalError(.gotMoreThanOneObjectForID(id))
		}
		
		let created: Bool
		let resultObject: PBXObject
		if let r = results.first {resultObject = r;                                              created = false}
		else                     {resultObject = PBXObject(entity: entity, insertInto: context); created = true}
		
		guard let result = resultObject as? Self else {
			if created {context.delete(resultObject)}
			throw Err.pbxProjParseError(.invalidObjectTypeFetchedOrCreated(expectedType: self), objectID: id)
		}
		
		do {
			result.setValue(id,  forKey: #keyPath(PBXObject.xcID))   /* Could be done in fillValues, but would require to give the id  to fillValues… */
			result.setValue(isa, forKey: #keyPath(PBXObject.rawISA)) /* Could be done in fillValues, but would require to give the isa to fillValues… */
			try result.fillValues(rawObject: rawObject, rawObjects: rawObjects, context: context, decodedObjects: &decodedObjects)
			decodedObjects[id] = result
			return result
		} catch {
			if created {
				context.delete(resultObject)
			}
			throw error
		}
	}
	
	static func getNonOptionalValue<T>(_ cdValue: T?, _ propertyName: String, _ objectID: String?) throws -> T {
		return try cdValue.get(orThrow: Err.invalidPBXProjObjectGraph(.missingProperty(propertyName: propertyName), objectID: objectID))
	}
	
	static func getOptionalToMany<T>(_ cdValue: NSOrderedSet?, _ isSetFlag: Bool) -> [T]? {
		guard isSetFlag else {
			assert((cdValue?.count ?? 0) == 0)
			return nil
		}
		return cdValue?.array as! [T]?
	}
	
	static func setOptionalToManyTuple<T>(_ newValue: [T]?) -> (NSOrderedSet?, Bool) {
		guard let v = newValue else {
			return (nil, false)
		}
		return (NSOrderedSet(array: v), true)
	}
	
	/*protected */open func fillValues(rawObject: [String: Any], rawObjects: [String: [String: Any]], context: NSManagedObjectContext, decodedObjects: inout [String: PBXObject]) throws {
		assert(context === managedObjectContext)
		self.rawObject = rawObject
		
		/* Let’s validate we know all the properties in the raw object. */
		let renamings = Self.propertyRenamings()
		let unknownProperties = Set(rawObject.keys).subtracting(entity.propertiesByName.keys.map{ renamings[$0] ?? $0 }).subtracting(["isa"])
		if !unknownProperties.isEmpty, let logger = Conf.logger {
			logger.warning("In object of type \(rawISA ?? "<unknown>"), instantiated w/ class \(entity.name ?? "<unknown>"), with ID \(xcID ?? "<unknown>"), got the following unknown properties: \(unknownProperties.sorted())")
		}
	}
	
	/**
	 Merge both serializations.
	 
	 If the child serialization overrides anything from the parent’s one, a warning is logged. */
	/*protected*/ func mergeSerialization(_ parent: [String: Any], _ child: [String: Any]) -> [String: Any] {
		return parent.merging(child, uniquingKeysWith: { current, new in
			Conf.logger?.warning("Child serialization overrode parent’s serialization’s value “\(current)” with “\(new)” for object of type \(rawISA ?? "<unknown>") with id \(xcID ?? "<unknown>").")
			return new
		})
	}
	
	/** The xcID of the object and its associated comment. */
	func xcIDAndComment(projectName: String) -> ValueAndComment? {
		return xcID.flatMap{ ValueAndComment(value: $0, comment: stringSerializationName(projectName: projectName)) }
	}
	
	func xcIDAndCommentString(projectName: String) -> String? {
		return xcIDAndComment(projectName: projectName)?.asString()
	}
	
	private func serializeAnyToString(_ v: Any, isRoot: Bool, projectName: String, indentCount: Int = 0, indentBase: String = "\t", oneline: Bool) throws -> String {
		func sortSerializationKeys(_ kv1: (String, Any), _ kv2: (String, Any), isaFirst: Bool) -> Bool {
			let (k1, k2) = (kv1.0, kv2.0)
			if isaFirst {
				if k1 == "isa" {return true}
				if k2 == "isa" {return false}
			}
			return k1 < k2
		}
		
		var ret = ""
		let indent = String(repeating: indentBase, count: indentCount)
		switch v {
			case let v as String:
				ret += v.escapedForPBXProjValue()
				
			case let v as ValueAndComment:
				ret += v.asString()
				
			case let v as ProjectReference:
				let dic = try [
					"ProjectRef": v.projectRef?.getIDAndCommentForSerialization("ProjectRef", xcID, projectName: projectName),
					"ProductGroup": v.productGroup?.getIDAndCommentForSerialization("ProductGroup", xcID, projectName: projectName)
				]
				ret += try serializeAnyToString(dic, isRoot: isRoot, projectName: projectName, indentCount: indentCount, indentBase: indentBase, oneline: oneline)
				
			case let a as [Any]:
				ret += "("
				for value in a {
					if !oneLineStringSerialization {ret += "\n\(indent)\(indentBase)"}
					ret += try serializeAnyToString(value, isRoot: false, projectName: projectName, indentCount: indentCount + 1, indentBase: indentBase, oneline: oneLineStringSerialization) + ","
					if oneLineStringSerialization {ret += " "}
				}
				if !oneLineStringSerialization {ret += "\n\(indent)"}
				ret += ")"
				
			case let d as [String: Any]:
				ret += "{"
				for (key, value) in d.sorted(by: { sortSerializationKeys($0, $1, isaFirst: isRoot) }) {
					if !oneLineStringSerialization {ret += "\n\(indent)\(indentBase)"}
					ret += try "\(key.escapedForPBXProjValue()) = \(serializeAnyToString(value, isRoot: false, projectName: projectName, indentCount: indentCount + 1, indentBase: indentBase, oneline: oneLineStringSerialization));"
					if oneLineStringSerialization {ret += " "}
				}
				if !oneLineStringSerialization {ret += "\n\(indent)"}
				ret += "}"
				
			default:
				throw Err.internalError(.unknownObjectTypeDuringSerialization(object: v))
		}
		return ret
	}
	
}
