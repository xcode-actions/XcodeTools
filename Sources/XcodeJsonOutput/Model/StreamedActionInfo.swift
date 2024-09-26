import Foundation



struct StreamedActionInfo : _Object {
	
	static let type: ObjectType = .init(name: "StreamedActionInfo")
	
	init(dictionary: [String : Any?], parentPropertyName: String?) throws {
		var dictionary = dictionary
		try Self.consumeAndValidateTypeFor(dictionary: &dictionary, parentPropertyName: parentPropertyName)
		
		Self.logUnknownKeys(from: dictionary)
	}
	
}
