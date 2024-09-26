import Foundation



struct ActionResult : _Object {
	
	static let type: ObjectType = .init(name: "ActionResult")
	
	var coverage: CodeCoverageInfo
	var issues: ResultIssueSummaries
	var metrics: ResultMetrics
	var resultName: String
	var status: String
	var testsRef: Reference?
	
	init(dictionary originalDictionary: [String : Any?], parentPropertyName: String?) throws {
		var dictionary = originalDictionary
		try Self.consumeAndValidateTypeFor(dictionary: &dictionary, parentPropertyName: parentPropertyName)
		
		self.coverage   = try dictionary.getParsedAndRemove("coverage", originalDictionary)
		self.issues     = try dictionary.getParsedAndRemove("issues", originalDictionary)
		self.metrics    = try dictionary.getParsedAndRemove("metrics", originalDictionary)
		self.resultName = try dictionary.getParsedAndRemove("resultName", originalDictionary)
		self.status     = try dictionary.getParsedAndRemove("status", originalDictionary)
		self.testsRef   = try dictionary.getParsedIfExistsAndRemove("testsRef", originalDictionary)
		
		Self.logUnknownKeys(from: dictionary)
	}
	
}
