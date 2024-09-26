import Foundation



struct ActionTestSummaryIdentifiableObject : _AnyActionTestSummaryIdentifiableObject {
	
	static let type: ObjectType = .init(name: "ActionTestSummaryIdentifiableObject", supertype: .init(name: "ActionAbstractTestSummary"))
	
	var identifier: String
	var name: String
	
	init(dictionary originalDictionary: [String : Any?], parentPropertyName: String?) throws {
		var dictionary = originalDictionary
		try Self.consumeAndValidateTypeFor(dictionary: &dictionary, parentPropertyName: parentPropertyName)
		
		self.identifier = try dictionary.getParsedAndRemove("identifier", originalDictionary)
		self.name       = try dictionary.getParsedAndRemove("name", originalDictionary)
		
		Self.logUnknownKeys(from: dictionary)
	}
	
}
