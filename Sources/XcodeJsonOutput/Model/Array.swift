import Foundation



extension Array : Object where Element : Object {
}


extension Array : _Object where Element : _Object {
	
	static var type: ObjectType {ObjectType(name: "Array")}
	
	init(dictionary originalDictionary: [String: Any?], parentPropertyName: String?) throws {
		var dictionary = originalDictionary
		try Self.consumeAndValidateTypeFor(dictionary: &dictionary, parentPropertyName: parentPropertyName)
		
		guard let values = dictionary.removeValue(forKey: "_values") as? [[String: Any?]] else {
			throw Err.invalidValueTypeOrMissingValue(parentPropertyName: parentPropertyName, expectedType: "[[String: Any?]]"/*, value: originalDictionary["_value"] as Any?*/)
		}
		
		self = try values.map{ try Element.init(dictionary: $0, parentPropertyName: parentPropertyName) }
		
		Self.logUnknownKeys(from: dictionary)
	}
	
}
