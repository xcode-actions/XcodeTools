import Foundation



public struct PBXNativeTarget : PBXTarget {
	
	public static var isa = "PBXNativeTarget"
	
	public let rawObject: [String: Any]
	
	public let name: String
	
	public let buildConfigurationList: XCConfigurationList
	
	/* Note: There are other known properties in this object, but we do not use
	 * them, so we do not mention them. */
	
	public init(rawObjects: [String: [String: Any]], id: String, factory: PBXObjectFactory) throws {
		guard let o = rawObjects[id], o["isa"] as? String == Self.isa else {
			throw HagvtoolError(message: "Cannot find object with id \(id) to init a \(Self.isa)")
		}
		rawObject = o
		
		name = try rawObject.get("name")
		
		let buildConfigurationListID: String = try rawObject.get("buildConfigurationList")
		buildConfigurationList = try XCConfigurationList(rawObjects: rawObjects, id: buildConfigurationListID, factory: factory)
	}
	
}
