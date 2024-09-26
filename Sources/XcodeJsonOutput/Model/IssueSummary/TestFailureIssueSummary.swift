import Foundation



struct TestFailureIssueSummary : _AnyIssueSummary {
	
	static let type: ObjectType = .init(name: "TestFailureIssueSummary", supertype: .init(name: "IssueSummary"))
	
	var issueType: String
	var message: String
	
	var testCaseName: String
	var producingTarget: String?
	var documentLocationInCreatingWorkspace: DocumentLocation
	
	init(dictionary originalDictionary: [String : Any?], parentPropertyName: String?) throws {
		var dictionary = originalDictionary
		try Self.consumeAndValidateTypeFor(dictionary: &dictionary, parentPropertyName: parentPropertyName)
		
		self.issueType = try dictionary.getParsedAndRemove("issueType", originalDictionary)
		self.message   = try dictionary.getParsedAndRemove("message", originalDictionary)
		
		self.testCaseName                        = try dictionary.getParsedAndRemove("testCaseName", originalDictionary)
		self.producingTarget                     = try dictionary.getParsedIfExistsAndRemove("producingTarget", originalDictionary)
		self.documentLocationInCreatingWorkspace = try dictionary.getParsedAndRemove("documentLocationInCreatingWorkspace", originalDictionary)
		
		Self.logUnknownKeys(from: dictionary)
	}
	
}
