import Foundation



struct StreamedActionResultInfo : _Object {
	
	static let type: ObjectType = .init(name: "StreamedActionResultInfo")
	
	var resultIndex: Int?
	
	init(dictionary originalDictionary: [String : Any?], parentPropertyName: String?) throws {
		var dictionary = originalDictionary
		try Self.consumeAndValidateTypeFor(dictionary: &dictionary, parentPropertyName: parentPropertyName)
		
		self.resultIndex = try dictionary.getParsedIfExistsAndRemove("resultIndex", originalDictionary)
		
		Self.logUnknownKeys(from: dictionary)
	}
	
}
