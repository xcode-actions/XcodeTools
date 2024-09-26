import Foundation



public enum XcodeJsonOutputError : Error {
	
	/** The given JSON cannot be parsed (JSON Serialization error) */
	case invalidJSON(Error)
	/** Deserialized JSON object is not of type `[String: Any?]` */
	case invalidJSONType
	
	/** The given dictionary does not have a `_type` property */
	case noObjectType//(objectDictionary: [String: Any?])
	/** The `_type` property of the dictionary object is invalid */
	case malformedObjectType//(typeObject: Any?)
	
	/** Trying to init an object with a dictionary whose type is incompatible. */
	case invalidObjectType(parentPropertyName: String?, expectedType: String/*, givenObjectDictionary: [String: Any?]*/)
	case missingProperty(_ propertyName: String/*, objectDictionary: [String: Any?]*/)
	case propertyValueIsNotDictionary(propertyName: String/*, objectDictionary: [String: Any?]*/)
	
	/** The `_value` property value is not of the expected type. */
	case invalidValueTypeOrMissingValue(parentPropertyName: String?, expectedType: String/*, value: Any?*/)
	
	case unknownObjectType(String/*, objectDictionary: [String: Any?]*/)
	
}

typealias Err = XcodeJsonOutputError
