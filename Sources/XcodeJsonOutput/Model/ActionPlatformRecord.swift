import Foundation



struct ActionPlatformRecord : _Object {
	
	static let type: ObjectType = .init(name: "ActionPlatformRecord")
	
	var identifier: String
	var userDescription: String
	
	init(dictionary originalDictionary: [String : Any?], parentPropertyName: String?) throws {
		var dictionary = originalDictionary
		try Self.consumeAndValidateTypeFor(dictionary: &dictionary, parentPropertyName: parentPropertyName)
		
		self.identifier      = try dictionary.getParsedAndRemove("identifier", originalDictionary)
		self.userDescription = try dictionary.getParsedAndRemove("userDescription", originalDictionary)
		
		Self.logUnknownKeys(from: dictionary)
	}
	
}
