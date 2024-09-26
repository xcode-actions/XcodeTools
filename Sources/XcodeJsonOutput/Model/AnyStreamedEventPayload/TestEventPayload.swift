import Foundation



struct TestEventPayload : _AnyStreamedEventPayload {
	
	static let type: ObjectType = .init(name: "TestEventPayload", supertype: .init(name: "AnyStreamedEventPayload"))
	
	var identifier: String?
	var name: String?
	var resultInfo: StreamedActionResultInfo
	var resultIndex: Int?
	
	var testIdentifier: AnyActionTestSummaryIdentifiableObject
	
	init(dictionary originalDictionary: [String : Any?], parentPropertyName: String?) throws {
		var dictionary = originalDictionary
		try Self.consumeAndValidateTypeFor(dictionary: &dictionary, parentPropertyName: parentPropertyName)
		
		self.identifier     = try dictionary.getParsedIfExistsAndRemove("identifier", originalDictionary)
		self.name           = try dictionary.getParsedIfExistsAndRemove("name", originalDictionary)
		self.resultInfo     = try dictionary.getParsedAndRemove("resultInfo", originalDictionary)
		self.resultIndex    = try dictionary.getParsedIfExistsAndRemove("resultIndex", originalDictionary)
		
		self.testIdentifier = try Parser.parseActionTestSummaryIdentifiableObject(
			dictionary: dictionary.getAndRemove(
				"testIdentifier",
				notFoundError: Err.missingProperty("testIdentifier"/*, objectDictionary: originalDictionary*/),
				wrongTypeError: Err.propertyValueIsNotDictionary(propertyName: "testIdentifier"/*, objectDictionary: originalDictionary*/)
			),
			parentPropertyName: "testIdentifier"
		)
		
		Self.logUnknownKeys(from: dictionary)
	}
	
	func humanReadableEvent(withColors: Bool) -> String? {
#warning("TODO")
		return nil
	}
	
}
