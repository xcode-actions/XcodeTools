import Foundation



struct LogSectionCreatedEventPayload : _AnyStreamedEventPayload {
	
	static let type: ObjectType = .init(name: "LogSectionCreatedEventPayload", supertype: .init(name: "AnyStreamedEventPayload"))
	
	var head: AnyActivityLogSectionHead
	var resultInfo: StreamedActionResultInfo
	var sectionIndex: Int
	
	init(dictionary originalDictionary: [String : Any?], parentPropertyName: String?) throws {
		var dictionary = originalDictionary
		try Self.consumeAndValidateTypeFor(dictionary: &dictionary, parentPropertyName: parentPropertyName)
		
		self.head         = try Parser.parseActivityLogSectionHead(
			dictionary: dictionary.getAndRemove(
				"head",
				notFoundError: Err.missingProperty("head"/*, objectDictionary: originalDictionary*/),
				wrongTypeError: Err.propertyValueIsNotDictionary(propertyName: "head"/*, objectDictionary: originalDictionary*/)
			),
			parentPropertyName: parentPropertyName
		)
		self.resultInfo   = try dictionary.getParsedAndRemove("resultInfo", originalDictionary)
		self.sectionIndex = try dictionary.getParsedAndRemove("sectionIndex", originalDictionary)
		
		Self.logUnknownKeys(from: dictionary)
	}
	
	func humanReadableEvent(withColors: Bool) -> String? {
		return head.title
	}
	
}
