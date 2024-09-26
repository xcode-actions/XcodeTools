import Foundation



struct ActionSDKRecord : _Object {
	
	static let type: ObjectType = .init(name: "ActionSDKRecord")
	
	var identifier: String
	var name: String
	var operatingSystemVersion: String
	
	init(dictionary originalDictionary: [String : Any?], parentPropertyName: String?) throws {
		var dictionary = originalDictionary
		try Self.consumeAndValidateTypeFor(dictionary: &dictionary, parentPropertyName: parentPropertyName)
		
		self.identifier             = try dictionary.getParsedAndRemove("identifier", originalDictionary)
		self.name                   = try dictionary.getParsedAndRemove("name", originalDictionary)
		self.operatingSystemVersion = try dictionary.getParsedAndRemove("operatingSystemVersion", originalDictionary)
		
		Self.logUnknownKeys(from: dictionary)
	}
	
}
