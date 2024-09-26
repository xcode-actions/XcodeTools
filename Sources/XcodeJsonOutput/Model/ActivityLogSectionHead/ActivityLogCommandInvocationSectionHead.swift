import Foundation



struct ActivityLogCommandInvocationSectionHead : _AnyActivityLogSectionHead {
	
	static let type: ObjectType = .init(name: "ActivityLogCommandInvocationSectionHead", supertype: .init(name: "ActivityLogSectionHead"))
	
	var commandDetails: String
	
	var domainType: String
	var location: DocumentLocation?
	var startTime: Date
	var title: String
	
	init(dictionary originalDictionary: [String : Any?], parentPropertyName: String?) throws {
		var dictionary = originalDictionary
		try Self.consumeAndValidateTypeFor(dictionary: &dictionary, parentPropertyName: parentPropertyName)
		
		self.commandDetails = try dictionary.getParsedAndRemove("commandDetails", originalDictionary)
		
		self.domainType = try dictionary.getParsedAndRemove("domainType", originalDictionary)
		self.location   = try dictionary.getParsedIfExistsAndRemove("location", originalDictionary)
		self.startTime  = try dictionary.getParsedAndRemove("startTime", originalDictionary)
		self.title      = try dictionary.getParsedAndRemove("title", originalDictionary)
		
		Self.logUnknownKeys(from: dictionary)
	}
	
}
