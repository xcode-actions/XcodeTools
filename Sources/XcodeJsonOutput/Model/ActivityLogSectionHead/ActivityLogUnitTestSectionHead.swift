import Foundation



struct ActivityLogUnitTestSectionHead : _AnyActivityLogSectionHead {
	
	static let type: ObjectType = .init(name: "ActivityLogUnitTestSectionHead", supertype: .init(name: "ActivityLogSectionHead"))
	
	var domainType: String
	var startTime: Date
	var title: String
	var suiteName: String?
	var testName: String?
	
	var runnableUTI: String?
	var runnablePath: String?
	
	init(dictionary originalDictionary: [String : Any?], parentPropertyName: String?) throws {
		var dictionary = originalDictionary
		try Self.consumeAndValidateTypeFor(dictionary: &dictionary, parentPropertyName: parentPropertyName)
		
		self.domainType = try dictionary.getParsedAndRemove("domainType", originalDictionary)
		self.startTime  = try dictionary.getParsedAndRemove("startTime", originalDictionary)
		self.title      = try dictionary.getParsedAndRemove("title", originalDictionary)
		self.suiteName  = try dictionary.getParsedIfExistsAndRemove("suiteName", originalDictionary)
		self.testName   = try dictionary.getParsedIfExistsAndRemove("testName", originalDictionary)
		
		self.runnableUTI  = try dictionary.getParsedIfExistsAndRemove("runnableUTI", originalDictionary)
		self.runnablePath = try dictionary.getParsedIfExistsAndRemove("runnablePath", originalDictionary)
		
		Self.logUnknownKeys(from: dictionary)
	}
	
}
