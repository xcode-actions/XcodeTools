import Foundation



struct ResultMetrics : _Object {
	
	static let type: ObjectType = .init(name: "ResultMetrics")
	
	var warningCount: Int
	var errorCount: Int
	
	var testsCount: Int
	var testsFailedCount: Int
	
	init(dictionary originalDictionary: [String : Any?], parentPropertyName: String?) throws {
		var dictionary = originalDictionary
		try Self.consumeAndValidateTypeFor(dictionary: &dictionary, parentPropertyName: parentPropertyName)
		
		self.warningCount = try dictionary.getParsedIfExistsAndRemove("warningCount", originalDictionary) ?? 0
		self.errorCount   = try dictionary.getParsedIfExistsAndRemove("errorCount", originalDictionary)   ?? 0
		
		self.testsCount       = try dictionary.getParsedIfExistsAndRemove("testsCount", originalDictionary)       ?? 0
		self.testsFailedCount = try dictionary.getParsedIfExistsAndRemove("testsFailedCount", originalDictionary) ?? 0
		
		Self.logUnknownKeys(from: dictionary)
	}
	
}
