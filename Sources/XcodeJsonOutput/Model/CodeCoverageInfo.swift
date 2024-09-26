import Foundation



struct CodeCoverageInfo : _Object {
	
	static let type: ObjectType = .init(name: "CodeCoverageInfo")
	
	init(dictionary: [String : Any?], parentPropertyName: String?) throws {
		var dictionary = dictionary
		try Self.consumeAndValidateTypeFor(dictionary: &dictionary, parentPropertyName: parentPropertyName)
		
		Self.logUnknownKeys(from: dictionary)
	}
	
}
