import Foundation



struct ActivityLogMessage : _Object {
	
	static let type: ObjectType = .init(name: "ActivityLogMessage")
	
	var title: String
	var shortTitle: String
	
	var type: String
	var category: String?
	
	var location: DocumentLocation?
	
	init(dictionary originalDictionary: [String : Any?], parentPropertyName: String?) throws {
		var dictionary = originalDictionary
		try Self.consumeAndValidateTypeFor(dictionary: &dictionary, parentPropertyName: parentPropertyName)
		
		self.title      = try dictionary.getParsedAndRemove("title", originalDictionary)
		self.shortTitle = try dictionary.getParsedAndRemove("shortTitle", originalDictionary)
		self.type       = try dictionary.getParsedAndRemove("type", originalDictionary)
		self.category   = try dictionary.getParsedIfExistsAndRemove("category", originalDictionary)
		self.location   = try dictionary.getParsedIfExistsAndRemove("location", originalDictionary)
		
		Self.logUnknownKeys(from: dictionary)
	}
	
}
