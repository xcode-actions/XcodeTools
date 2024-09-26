import Foundation



extension Date : _Object {
	
	static let type = ObjectType(name: "Date")
	
	init(dictionary originalDictionary: [String: Any?], parentPropertyName: String?) throws {
		var dictionary = originalDictionary
		try Self.consumeAndValidateTypeFor(dictionary: &dictionary, parentPropertyName: parentPropertyName)
		
		guard
			let valueStr = dictionary.removeValue(forKey: "_value") as? String,
			let value = try? Date(valueStr, strategy: Self.dateStyle)
		else {
			throw Err.invalidValueTypeOrMissingValue(parentPropertyName: parentPropertyName, expectedType: "Date"/*, value: originalDictionary["_value"] as Any?*/)
		}
		
		self = value
		
		Self.logUnknownKeys(from: dictionary)
	}
	
	private static let dateStyle = Date.ISO8601FormatStyle.iso8601
	
}
