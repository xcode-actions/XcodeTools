import Foundation



struct ActionRecordTail : _Object {
	
	static let type: ObjectType = .init(name: "ActionRecordTail")
	
	var actionResult: ActionResult
	var buildResult: ActionResult
	var endedTime: Date
	
	init(dictionary originalDictionary: [String : Any?], parentPropertyName: String?) throws {
		var dictionary = originalDictionary
		try Self.consumeAndValidateTypeFor(dictionary: &dictionary, parentPropertyName: parentPropertyName)
		
		self.actionResult = try dictionary.getParsedAndRemove("actionResult", originalDictionary)
		self.buildResult  = try dictionary.getParsedAndRemove("buildResult", originalDictionary)
		self.endedTime    = try dictionary.getParsedAndRemove("endedTime", originalDictionary)
		
		Self.logUnknownKeys(from: dictionary)
	}
	
}
