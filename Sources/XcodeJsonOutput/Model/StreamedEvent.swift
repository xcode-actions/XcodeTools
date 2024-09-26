import Foundation



public struct StreamedEvent : _Object {
	
	static let type = ObjectType(name: "StreamedEvent")
	
	public var name: String
	public var structuredPayload: AnyStreamedEventPayload
	
	init(dictionary originalDictionary: [String: Any?], parentPropertyName: String?) throws {
		var dictionary = originalDictionary
		try Self.consumeAndValidateTypeFor(dictionary: &dictionary, parentPropertyName: parentPropertyName)
		
		self.name              = try dictionary.getParsedAndRemove("name", originalDictionary)
		self.structuredPayload = try Parser.parsePayload(
			dictionary: dictionary.getAndRemove(
				"structuredPayload",
				notFoundError: Err.missingProperty("structuredPayload"/*, objectDictionary: originalDictionary*/),
				wrongTypeError: Err.propertyValueIsNotDictionary(propertyName: "structuredPayload"/*, objectDictionary: originalDictionary*/)
			),
			parentPropertyName: "structuredPayload"
		)
		
		Self.logUnknownKeys(from: dictionary)
	}
	
}
