import Foundation



struct ResultIssueSummaries : _Object {
	
	static let type: ObjectType = .init(name: "ResultIssueSummaries")
	
	var warningSummaries: [IssueSummary]
	var errorSummaries: [IssueSummary]
	var testFailureSummaries: [TestFailureIssueSummary]
	
	init(dictionary originalDictionary: [String : Any?], parentPropertyName: String?) throws {
		var dictionary = originalDictionary
		try Self.consumeAndValidateTypeFor(dictionary: &dictionary, parentPropertyName: parentPropertyName)
		
		self.warningSummaries     = try dictionary.getParsedIfExistsAndRemove("warningSummaries", originalDictionary)     ?? []
		self.errorSummaries       = try dictionary.getParsedIfExistsAndRemove("errorSummaries", originalDictionary)       ?? []
		self.testFailureSummaries = try dictionary.getParsedIfExistsAndRemove("testFailureSummaries", originalDictionary) ?? []
		
		Self.logUnknownKeys(from: dictionary)
	}
	
}
