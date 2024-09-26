import Foundation



struct Reference : _Object {
	
	static let type: ObjectType = .init(name: "Reference")
	
	var id: String
	var targetType: TypeDefinition
	
	init(dictionary originalDictionary: [String : Any?], parentPropertyName: String?) throws {
		var dictionary = originalDictionary
		try Self.consumeAndValidateTypeFor(dictionary: &dictionary, parentPropertyName: parentPropertyName)
		
		self.id         = try dictionary.getParsedAndRemove("id", originalDictionary)
		self.targetType = try dictionary.getParsedAndRemove("targetType", originalDictionary)
		
		Self.logUnknownKeys(from: dictionary)
	}
	
}
