import Foundation



struct ActionRunDestinationRecord : _Object {
	
	static let type: ObjectType = .init(name: "ActionRunDestinationRecord")
	
	var displayName: String
	var localComputerRecord: ActionDeviceRecord
	var targetArchitecture: String
	var targetDeviceRecord: ActionDeviceRecord
	var targetSDKRecord: ActionSDKRecord
	
	init(dictionary originalDictionary: [String : Any?], parentPropertyName: String?) throws {
		var dictionary = originalDictionary
		try Self.consumeAndValidateTypeFor(dictionary: &dictionary, parentPropertyName: parentPropertyName)
		
		self.displayName         = try dictionary.getParsedAndRemove("displayName", originalDictionary)
		self.localComputerRecord = try dictionary.getParsedAndRemove("localComputerRecord", originalDictionary)
		self.targetArchitecture  = try dictionary.getParsedAndRemove("targetArchitecture", originalDictionary)
		self.targetDeviceRecord  = try dictionary.getParsedAndRemove("targetDeviceRecord", originalDictionary)
		self.targetSDKRecord     = try dictionary.getParsedAndRemove("targetSDKRecord", originalDictionary)
		
		Self.logUnknownKeys(from: dictionary)
	}
	
}
