import Foundation



struct ActivityLogUnitTestSectionTail : _AnyActivityLogSectionTail {
	
	static let type: ObjectType = .init(name: "ActivityLogUnitTestSectionTail", supertype: .init(name: "ActivityLogSectionTail"))
	
	var duration: Double
	var summary: String?
	var result: String
	var testsPassedString: String?
	
	init(dictionary originalDictionary: [String : Any?], parentPropertyName: String?) throws {
		var dictionary = originalDictionary
		try Self.consumeAndValidateTypeFor(dictionary: &dictionary, parentPropertyName: parentPropertyName)
		
		self.duration          = try dictionary.getParsedAndRemove("duration", originalDictionary)
		self.summary           = try dictionary.getParsedIfExistsAndRemove("summary", originalDictionary)
		self.result            = try dictionary.getParsedAndRemove("result", originalDictionary)
		self.testsPassedString = try dictionary.getParsedIfExistsAndRemove("testsPassedString", originalDictionary)
		
		Self.logUnknownKeys(from: dictionary)
	}
	
}
