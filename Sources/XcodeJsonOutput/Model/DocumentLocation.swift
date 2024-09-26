import Foundation



struct DocumentLocation : _Object {
	
	static let type: ObjectType = .init(name: "DocumentLocation")
	
	var concreteTypeName: String
	var url: URL
	
	init(dictionary originalDictionary: [String : Any?], parentPropertyName: String?) throws {
		var dictionary = originalDictionary
		try Self.consumeAndValidateTypeFor(dictionary: &dictionary, parentPropertyName: parentPropertyName)
		
		self.concreteTypeName = try dictionary.getParsedAndRemove("concreteTypeName", originalDictionary)
		let urlString: String = try dictionary.getParsedAndRemove("url", originalDictionary)
		
		guard let url = URL(string: urlString) else {
			throw Err.invalidObjectType(parentPropertyName: "url", expectedType: "URL"/*, givenObjectDictionary: ["_value": urlString]*/)
		}
		self.url = url
		
		Self.logUnknownKeys(from: dictionary)
	}
	
}
