import Foundation



struct IssueSummary : _AnyIssueSummary {
	
	static let type: ObjectType = .init(name: "IssueSummary")
	
	var issueType: String
	var message: String
	var documentLocationInCreatingWorkspace: DocumentLocation?
	
	init(dictionary originalDictionary: [String : Any?], parentPropertyName: String?) throws {
		var dictionary = originalDictionary
		try Self.consumeAndValidateTypeFor(dictionary: &dictionary, parentPropertyName: parentPropertyName)
		
		self.issueType = try dictionary.getParsedAndRemove("issueType", originalDictionary)
		self.message   = try dictionary.getParsedAndRemove("message", originalDictionary)
		
		self.documentLocationInCreatingWorkspace = try dictionary.getParsedIfExistsAndRemove("documentLocationInCreatingWorkspace", originalDictionary)
		
		Self.logUnknownKeys(from: dictionary)
	}
	
}
