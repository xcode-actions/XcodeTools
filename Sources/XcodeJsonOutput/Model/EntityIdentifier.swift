import Foundation



struct EntityIdentifier : _Object {
	
	static let type: ObjectType = .init(name: "EntityIdentifier")
	
	var containerName: String
	var entityName: String
	var entityType: String
	var sharedState: String
	
	init(dictionary originalDictionary: [String : Any?], parentPropertyName: String?) throws {
		var dictionary = originalDictionary
		try Self.consumeAndValidateTypeFor(dictionary: &dictionary, parentPropertyName: parentPropertyName)
		
		self.containerName = try dictionary.getParsedAndRemove("containerName", originalDictionary)
		self.entityName    = try dictionary.getParsedAndRemove("entityName", originalDictionary)
		self.entityType    = try dictionary.getParsedAndRemove("entityType", originalDictionary)
		self.sharedState   = try dictionary.getParsedAndRemove("sharedState", originalDictionary)
		
		Self.logUnknownKeys(from: dictionary)
	}
	
}
