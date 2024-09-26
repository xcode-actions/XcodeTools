import Foundation



struct LogMessageEmittedEventPayload : _AnyStreamedEventPayload {
	
	static let type: ObjectType = .init(name: "LogMessageEmittedEventPayload", supertype: .init(name: "AnyStreamedEventPayload"))
	
	var message: ActivityLogMessage
	var resultInfo: StreamedActionResultInfo
	var sectionIndex: Int
	
	init(dictionary originalDictionary: [String : Any?], parentPropertyName: String?) throws {
		var dictionary = originalDictionary
		try Self.consumeAndValidateTypeFor(dictionary: &dictionary, parentPropertyName: parentPropertyName)
		
		self.message      = try dictionary.getParsedAndRemove("message", originalDictionary)
		self.resultInfo   = try dictionary.getParsedAndRemove("resultInfo", originalDictionary)
		self.sectionIndex = try dictionary.getParsedAndRemove("sectionIndex", originalDictionary)
		
		Self.logUnknownKeys(from: dictionary)
	}
	
	func humanReadableEvent(withColors: Bool) -> String? {
#warning("TODO")
		return nil
	}
	
}
