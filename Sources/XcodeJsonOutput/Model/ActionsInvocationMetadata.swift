import Foundation



struct ActionsInvocationMetadata : _Object {
	
	static let type: ObjectType = .init(name: "ActionsInvocationMetadata")
	
	var creatingWorkspaceFilePath: String
	var schemeIdentifier: EntityIdentifier
	var uniqueIdentifier: String
	
	init(dictionary originalDictionary: [String : Any?], parentPropertyName: String?) throws {
		var dictionary = originalDictionary
		try Self.consumeAndValidateTypeFor(dictionary: &dictionary, parentPropertyName: parentPropertyName)
		
		self.creatingWorkspaceFilePath = try dictionary.getParsedAndRemove("creatingWorkspaceFilePath", originalDictionary)
		self.schemeIdentifier          = try dictionary.getParsedAndRemove("schemeIdentifier", originalDictionary)
		self.uniqueIdentifier          = try dictionary.getParsedAndRemove("uniqueIdentifier", originalDictionary)
		
		Self.logUnknownKeys(from: dictionary)
	}
	
}
