import Foundation



struct LogTextAppendedEventPayload : _AnyStreamedEventPayload {
	
	static let type: ObjectType = .init(name: "LogTextAppendedEventPayload", supertype: .init(name: "AnyStreamedEventPayload"))
	
	var resultInfo: StreamedActionResultInfo
	var sectionIndex: Int
	var text: String
	
	init(dictionary originalDictionary: [String : Any?], parentPropertyName: String?) throws {
		var dictionary = originalDictionary
		try Self.consumeAndValidateTypeFor(dictionary: &dictionary, parentPropertyName: parentPropertyName)
		
		self.resultInfo   = try dictionary.getParsedAndRemove("resultInfo", originalDictionary)
		self.sectionIndex = try dictionary.getParsedAndRemove("sectionIndex", originalDictionary)
		self.text         = try dictionary.getParsedIfExistsAndRemove("text", originalDictionary) ?? ""
		
		Self.logUnknownKeys(from: dictionary)
	}
	
	func humanReadableEvent(withColors: Bool) -> String? {
#warning("TODO")
		return nil
	}
	
}
