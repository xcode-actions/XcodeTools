import Foundation



struct ActionTestSummaryGroup : _AnyActionTestSummaryIdentifiableObject {
	
	static let type: ObjectType = .init(name: "ActionTestSummaryGroup", supertype: .init(name: "ActionTestSummaryIdentifiableObject", supertype: .init(name: "ActionAbstractTestSummary")))
	
	var identifier: String
	var name: String
	var duration: Double?
	var subtests: [AnyActionTestSummaryIdentifiableObject]?
	
	init(dictionary originalDictionary: [String : Any?], parentPropertyName: String?) throws {
		var dictionary = originalDictionary
		try Self.consumeAndValidateTypeFor(dictionary: &dictionary, parentPropertyName: parentPropertyName)
		
		self.identifier = try dictionary.getParsedAndRemove("identifier", originalDictionary)
		self.name       = try dictionary.getParsedAndRemove("name", originalDictionary)
		self.duration   = try dictionary.getParsedIfExistsAndRemove("duration", originalDictionary)
		
		self.subtests = try dictionary.getIfExistsAndRemove(
			"subtests",
			wrongTypeError: Err.propertyValueIsNotDictionary(propertyName: "subtests"/*, objectDictionary: originalDictionary*/)
		)
		.flatMap{ try Parser.parseArrayOfActionTestSummaryIdentifiableObject(arrayObject: $0, parentPropertyName: "subtests") }
		
		Self.logUnknownKeys(from: dictionary)
	}
	
}
