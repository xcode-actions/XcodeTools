import Foundation



struct ActionDeviceRecord : _Object {
	
	static let type: ObjectType = .init(name: "ActionDeviceRecord")
	
	var busSpeedInMHz: Int?
	var cpuCount: Int?
	var cpuKind: String?
	var cpuSpeedInMHz: Int?
	var identifier: String
	var isConcreteDevice: Bool?
	var logicalCPUCoresPerPackage: Int?
	var modelCode: String
	var modelName: String
	var modelUTI: String
	var name: String
	var nativeArchitecture: String
	var operatingSystemVersion: String?
	var operatingSystemVersionWithBuildNumber: String?
	var physicalCPUCoresPerPackage: Int?
	var platformRecord: ActionPlatformRecord
	var ramSizeInMegabytes: Int?
	
	init(dictionary originalDictionary: [String : Any?], parentPropertyName: String?) throws {
		var dictionary = originalDictionary
		try Self.consumeAndValidateTypeFor(dictionary: &dictionary, parentPropertyName: parentPropertyName)
		
		self.identifier         = try dictionary.getParsedAndRemove("identifier", originalDictionary)
		self.modelCode          = try dictionary.getParsedAndRemove("modelCode", originalDictionary)
		self.modelName          = try dictionary.getParsedAndRemove("modelName", originalDictionary)
		self.modelUTI           = try dictionary.getParsedAndRemove("modelUTI", originalDictionary)
		self.name               = try dictionary.getParsedAndRemove("name", originalDictionary)
		self.nativeArchitecture = try dictionary.getParsedAndRemove("nativeArchitecture", originalDictionary)
		self.platformRecord     = try dictionary.getParsedAndRemove("platformRecord", originalDictionary)
		
		self.busSpeedInMHz                         = try dictionary.getParsedIfExistsAndRemove("busSpeedInMHz", originalDictionary)
		self.cpuCount                              = try dictionary.getParsedIfExistsAndRemove("cpuCount", originalDictionary)
		self.cpuKind                               = try dictionary.getParsedIfExistsAndRemove("cpuKind", originalDictionary)
		self.cpuSpeedInMHz                         = try dictionary.getParsedIfExistsAndRemove("cpuSpeedInMHz", originalDictionary)
		self.isConcreteDevice                      = try dictionary.getParsedIfExistsAndRemove("isConcreteDevice", originalDictionary)
		self.logicalCPUCoresPerPackage             = try dictionary.getParsedIfExistsAndRemove("logicalCPUCoresPerPackage", originalDictionary)
		self.operatingSystemVersion                = try dictionary.getParsedIfExistsAndRemove("operatingSystemVersion", originalDictionary)
		self.operatingSystemVersionWithBuildNumber = try dictionary.getParsedIfExistsAndRemove("operatingSystemVersionWithBuildNumber", originalDictionary)
		self.physicalCPUCoresPerPackage            = try dictionary.getParsedIfExistsAndRemove("physicalCPUCoresPerPackage", originalDictionary)
		self.ramSizeInMegabytes                    = try dictionary.getParsedIfExistsAndRemove("ramSizeInMegabytes", originalDictionary)
		
		Self.logUnknownKeys(from: dictionary)
	}
	
}
