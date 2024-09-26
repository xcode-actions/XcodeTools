import Foundation



struct TestFinishedEventPayload : _AnyStreamedEventPayload {
	
	static let type: ObjectType = .init(name: "TestFinishedEventPayload", supertype: .init(name: "AnyStreamedEventPayload"))
	
	var resultInfo: StreamedActionResultInfo
	var test: ActionTestMetadata
	var duration: Double?
	var identifier: String?
	var name: String?
	var testStatus: String?
	
	init(dictionary originalDictionary: [String : Any?], parentPropertyName: String?) throws {
		var dictionary = originalDictionary
		try Self.consumeAndValidateTypeFor(dictionary: &dictionary, parentPropertyName: parentPropertyName)
		
		self.resultInfo = try dictionary.getParsedAndRemove("resultInfo", originalDictionary)
		self.test       = try dictionary.getParsedAndRemove("test", originalDictionary)
		self.duration   = try dictionary.getParsedIfExistsAndRemove("duration", originalDictionary)
		self.identifier = try dictionary.getParsedIfExistsAndRemove("identifier", originalDictionary)
		self.name       = try dictionary.getParsedIfExistsAndRemove("name", originalDictionary)
		self.testStatus = try dictionary.getParsedIfExistsAndRemove("testStatus", originalDictionary)
		
		Self.logUnknownKeys(from: dictionary)
	}
	
	func humanReadableEvent(withColors: Bool) -> String? {
#warning("TODO")
		return nil
	}
	
}
