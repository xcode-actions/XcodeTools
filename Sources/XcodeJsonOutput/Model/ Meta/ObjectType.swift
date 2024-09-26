import Foundation



struct ObjectType : Equatable, CustomStringConvertible, Sendable {
	
	var name: String
	@Indirect
	var supertype: ObjectType?
	
	init(name: String, supertype: ObjectType? = nil) {
		self.name = name
		self.supertype = supertype
	}
	
	init(dictionary: [String: Any?]) throws {
		let typeDic: [String: Any?] = try dictionary.get(
			"_type",
			notFoundError: Err.noObjectType/*(objectDictionary: dictionary)*/,
			wrongTypeError: Err.malformedObjectType//(typeObject: dictionary["_type"]!)
		)
		try self.init(typeDictionary: typeDic)
	}
	
	init(typeDictionary: [String: Any?]) throws {
		let name: String = try typeDictionary.get("_name", notFoundError: Err.malformedObjectType/*(typeObject: typeDictionary)*/, wrongTypeError: Err.malformedObjectType/*(typeObject: typeDictionary)*/)
		
		let supertype: ObjectType?
		if let supertypeDictionary: [String: Any?] = try typeDictionary.getIfExists("_supertype", wrongTypeError: Err.malformedObjectType/*(typeObject: typeDictionary)*/) {
			guard typeDictionary.count == 2 else {
				throw Err.malformedObjectType/*(typeObject: typeDictionary)*/
			}
			supertype = try ObjectType(typeDictionary: supertypeDictionary)
		} else {
			guard typeDictionary.count == 1 else {
				throw Err.malformedObjectType/*(typeObject: typeDictionary)*/
			}
			supertype = nil
		}
		
		self.init(name: name, supertype: supertype)
	}
	
	var description: String {
		return "ObjectType<\(name)\((supertype.flatMap{ ", \($0)" } ?? ""))>"
	}
	
	static func ==(lhs: ObjectType, rhs: ObjectType) -> Bool {
		return lhs.name == rhs.name && lhs.supertype == rhs.supertype
	}
	
}
