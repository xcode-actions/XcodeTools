import Foundation



struct LogSectionClosedEventPayload : _AnyStreamedEventPayload {
	
	static let type: ObjectType = .init(name: "LogSectionClosedEventPayload", supertype: .init(name: "AnyStreamedEventPayload"))
	
	var resultInfo: StreamedActionResultInfo
	var sectionIndex: Int
	var tail: AnyActivityLogSectionTail
	
	init(dictionary originalDictionary: [String : Any?], parentPropertyName: String?) throws {
		var dictionary = originalDictionary
		try Self.consumeAndValidateTypeFor(dictionary: &dictionary, parentPropertyName: parentPropertyName)
		
		self.resultInfo   = try dictionary.getParsedAndRemove("resultInfo", originalDictionary)
		self.sectionIndex = try dictionary.getParsedAndRemove("sectionIndex", originalDictionary)
		self.tail         = try Parser.parseActivityLogSectionTail(
			dictionary: dictionary.getAndRemove(
				"tail",
				notFoundError: Err.missingProperty("tail"/*, objectDictionary: originalDictionary*/),
				wrongTypeError: Err.propertyValueIsNotDictionary(propertyName: "tail"/*, objectDictionary: originalDictionary*/)
			),
			parentPropertyName: parentPropertyName
		)
		
		Self.logUnknownKeys(from: dictionary)
	}
	
	func humanReadableEvent(withColors: Bool) -> String? {
#warning("TODO")
		return nil
	}
	
}
