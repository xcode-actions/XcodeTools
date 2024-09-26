import Foundation



extension String : _Object {
	
	static let type = ObjectType(name: "String")
	
	init(dictionary originalDictionary: [String: Any?], parentPropertyName: String?) throws {
		var dictionary = originalDictionary
		try Self.consumeAndValidateTypeFor(dictionary: &dictionary, parentPropertyName: parentPropertyName)
		
		guard
			let value = dictionary.removeValue(forKey: "_value") as? String
		else {
			throw Err.invalidValueTypeOrMissingValue(parentPropertyName: parentPropertyName, expectedType: "String"/*, value: originalDictionary["_value"] as Any?*/)
		}
		
		self = value
		
		Self.logUnknownKeys(from: dictionary)
	}
	
}
