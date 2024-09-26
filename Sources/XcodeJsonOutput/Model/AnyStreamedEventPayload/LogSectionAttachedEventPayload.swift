import Foundation



struct LogSectionAttachedEventPayload : _AnyStreamedEventPayload {
	
	static let type: ObjectType = .init(name: "LogSectionAttachedEventPayload", supertype: .init(name: "AnyStreamedEventPayload"))
	
	var childSectionIndex: Int
	var parentSectionIndex: Int?
	var resultInfo: StreamedActionResultInfo
	
	init(dictionary originalDictionary: [String : Any?], parentPropertyName: String?) throws {
		var dictionary = originalDictionary
		try Self.consumeAndValidateTypeFor(dictionary: &dictionary, parentPropertyName: parentPropertyName)
		
		self.childSectionIndex  = try dictionary.getParsedAndRemove("childSectionIndex", originalDictionary)
		self.parentSectionIndex = try dictionary.getParsedIfExistsAndRemove("parentSectionIndex", originalDictionary)
		self.resultInfo         = try dictionary.getParsedAndRemove("resultInfo", originalDictionary)
		
		Self.logUnknownKeys(from: dictionary)
	}
	
	func humanReadableEvent(withColors: Bool) -> String? {
#warning("TODO")
		return nil
	}
	
}
