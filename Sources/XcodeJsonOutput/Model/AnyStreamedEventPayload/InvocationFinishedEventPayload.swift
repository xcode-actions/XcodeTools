import Foundation



struct InvocationFinishedEventPayload : _AnyStreamedEventPayload {
	
	static let type: ObjectType = .init(name: "InvocationFinishedEventPayload", supertype: .init(name: "AnyStreamedEventPayload"))
	
	var recordRef: Reference
	
	init(dictionary originalDictionary: [String : Any?], parentPropertyName: String?) throws {
		var dictionary = originalDictionary
		try Self.consumeAndValidateTypeFor(dictionary: &dictionary, parentPropertyName: parentPropertyName)
		
		self.recordRef = try dictionary.getParsedAndRemove("recordRef", originalDictionary)
		
		Self.logUnknownKeys(from: dictionary)
	}
	
	func humanReadableEvent(withColors: Bool) -> String? {
#warning("TODO")
		return nil
	}
	
}
