import Foundation

import GlobalConfModule



public protocol Object {
}


protocol _Object : Object {
	
	static var type: ObjectType {get}
	init(dictionary: [String: Any?], parentPropertyName: String?) throws
	
}


extension _Object {
	
	/**
	 Convenience one can call at start of concrete init implementations to validate the type of the dictionary that has been passed in. */
	static func consumeAndValidateTypeFor(dictionary: inout [String: Any?], parentPropertyName: String?) throws {
		guard try ObjectType(dictionary: dictionary) == Self.type else {
			throw Err.invalidObjectType(parentPropertyName: parentPropertyName, expectedType: "\(Self.type)"/*, givenObjectDictionary: dictionary*/)
		}
		assert(dictionary.keys.contains("_type"))
		dictionary.removeValue(forKey: "_type")
	}
	
	static func logUnknownKeys(from dictionary: [String: Any?]) {
		guard !dictionary.isEmpty else {return}
		Conf.logger?.warning("Got unknown keys in object of type \(Self.type): \(dictionary)")
	}
	
}
