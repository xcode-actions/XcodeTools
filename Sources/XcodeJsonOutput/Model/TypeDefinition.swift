import Foundation



public struct TypeDefinition : _Object {
	
	static let type = ObjectType(name: "TypeDefinition")
	
	public var name: String
	public var supertype: Object? //TypeDefinition
	
	init(dictionary originalDictionary: [String: Any?], parentPropertyName: String?) throws {
		var dictionary = originalDictionary
		try Self.consumeAndValidateTypeFor(dictionary: &dictionary, parentPropertyName: parentPropertyName)
		
		self.name      = try dictionary.getParsedAndRemove("name", originalDictionary)
		self.supertype = try dictionary.getIfExistsAndRemove(
			"supertype",
			wrongTypeError: Err.propertyValueIsNotDictionary(propertyName: "supertype"/*, objectDictionary: originalDictionary*/)
		)
		.flatMap{ try Parser.parse(dictionary: $0, parentPropertyName: "supertype") }
		
		Self.logUnknownKeys(from: dictionary)
	}
	
}
