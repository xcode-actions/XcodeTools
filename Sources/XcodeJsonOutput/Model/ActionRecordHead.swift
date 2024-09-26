import Foundation



struct ActionRecordHead : _Object {
	
	static let type: ObjectType = .init(name: "ActionRecordHead")
	
	var runDestination: ActionRunDestinationRecord
	var schemeCommandName: String
	var schemeTaskName: String
	var startedTime: Date
	
	init(dictionary originalDictionary: [String : Any?], parentPropertyName: String?) throws {
		var dictionary = originalDictionary
		try Self.consumeAndValidateTypeFor(dictionary: &dictionary, parentPropertyName: parentPropertyName)
		
		self.runDestination    = try dictionary.getParsedAndRemove("runDestination", originalDictionary)
		self.schemeCommandName = try dictionary.getParsedAndRemove("schemeCommandName", originalDictionary)
		self.schemeTaskName    = try dictionary.getParsedAndRemove("schemeTaskName", originalDictionary)
		self.startedTime       = try dictionary.getParsedAndRemove("startedTime", originalDictionary)
		
		Self.logUnknownKeys(from: dictionary)
	}
	
}
