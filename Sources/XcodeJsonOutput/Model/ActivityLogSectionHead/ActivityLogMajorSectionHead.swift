import Foundation



struct ActivityLogMajorSectionHead : _AnyActivityLogSectionHead {
	
	static let type: ObjectType = .init(name: "ActivityLogMajorSectionHead", supertype: .init(name: "ActivityLogSectionHead"))
	
	var domainType: String
	var startTime: Date
	var title: String
	
	init(dictionary originalDictionary: [String : Any?], parentPropertyName: String?) throws {
		var dictionary = originalDictionary
		try Self.consumeAndValidateTypeFor(dictionary: &dictionary, parentPropertyName: parentPropertyName)
		
		self.domainType = try dictionary.getParsedAndRemove("domainType", originalDictionary)
		self.startTime  = try dictionary.getParsedAndRemove("startTime", originalDictionary)
		self.title      = try dictionary.getParsedAndRemove("title", originalDictionary)
		
		Self.logUnknownKeys(from: dictionary)
	}
	
}
