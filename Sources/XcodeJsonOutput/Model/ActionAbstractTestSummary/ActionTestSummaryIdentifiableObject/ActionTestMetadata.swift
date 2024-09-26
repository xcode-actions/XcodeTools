import Foundation



struct ActionTestMetadata : _AnyActionTestSummaryIdentifiableObject {
	
	static let type: ObjectType = .init(name: "ActionTestMetadata", supertype: .init(name: "ActionTestSummaryIdentifiableObject", supertype: .init(name: "ActionAbstractTestSummary")))
	
	var identifier: String
	var name: String
	var duration: Double
	var testStatus: String
	var summaryRef: Reference?
	
	init(dictionary originalDictionary: [String : Any?], parentPropertyName: String?) throws {
		var dictionary = originalDictionary
		try Self.consumeAndValidateTypeFor(dictionary: &dictionary, parentPropertyName: parentPropertyName)
		
		self.identifier = try dictionary.getParsedAndRemove("identifier", originalDictionary)
		self.name       = try dictionary.getParsedAndRemove("name", originalDictionary)
		self.duration   = try dictionary.getParsedAndRemove("duration", originalDictionary)
		self.testStatus = try dictionary.getParsedAndRemove("testStatus", originalDictionary)
		self.summaryRef = try dictionary.getParsedIfExistsAndRemove("summaryRef", originalDictionary)
		
		Self.logUnknownKeys(from: dictionary)
	}
	
}
