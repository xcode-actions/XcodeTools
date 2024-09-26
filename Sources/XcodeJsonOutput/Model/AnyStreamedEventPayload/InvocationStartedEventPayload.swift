import Foundation



struct InvocationStartedEventPayload : _AnyStreamedEventPayload {
	
	static let type: ObjectType = .init(name: "InvocationStartedEventPayload", supertype: .init(name: "AnyStreamedEventPayload"))
	
	var metadata: ActionsInvocationMetadata
	
	init(dictionary originalDictionary: [String : Any?], parentPropertyName: String?) throws {
		var dictionary = originalDictionary
		try Self.consumeAndValidateTypeFor(dictionary: &dictionary, parentPropertyName: parentPropertyName)
		
		self.metadata = try dictionary.getParsedAndRemove("metadata", originalDictionary)
		
		Self.logUnknownKeys(from: dictionary)
	}
	
	func humanReadableEvent(withColors: Bool) -> String? {
#warning("TODO")
		return nil
	}
	
}
