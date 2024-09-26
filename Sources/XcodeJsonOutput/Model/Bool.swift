import Foundation



extension Bool : _Object {
	
	static let type = ObjectType(name: "Bool")
	
	init(dictionary originalDictionary: [String: Any?], parentPropertyName: String?) throws {
		var dictionary = originalDictionary
		try Self.consumeAndValidateTypeFor(dictionary: &dictionary, parentPropertyName: parentPropertyName)
		
		guard
			let valueStr = dictionary.removeValue(forKey: "_value") as? String,
			let value = Bool(valueStr)
		else {
			throw Err.invalidValueTypeOrMissingValue(parentPropertyName: parentPropertyName, expectedType: "Bool"/*, value: originalDictionary["_value"] as Any?*/)
		}
		
		self = value
		
		Self.logUnknownKeys(from: dictionary)
	}
	
}
