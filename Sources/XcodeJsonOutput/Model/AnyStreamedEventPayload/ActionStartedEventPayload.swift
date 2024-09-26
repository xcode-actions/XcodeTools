import Foundation



struct ActionStartedEventPayload : _AnyStreamedEventPayload {
	
	static let type: ObjectType = .init(name: "ActionStartedEventPayload", supertype: .init(name: "AnyStreamedEventPayload"))
	
	var actionInfo: StreamedActionInfo
	var head: ActionRecordHead
	
	init(dictionary originalDictionary: [String : Any?], parentPropertyName: String?) throws {
		var dictionary = originalDictionary
		try Self.consumeAndValidateTypeFor(dictionary: &dictionary, parentPropertyName: parentPropertyName)
		
		self.actionInfo = try dictionary.getParsedAndRemove("actionInfo", originalDictionary)
		self.head       = try dictionary.getParsedAndRemove("head", originalDictionary)
		
		Self.logUnknownKeys(from: dictionary)
	}
	
	func humanReadableEvent(withColors: Bool) -> String? {
#warning("TODO")
		return nil
	}
	
}
