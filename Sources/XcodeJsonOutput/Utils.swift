import Foundation

import Utils



extension Dictionary where Key == String {
	
	/* A small semantic glitch: If the value exists but is invalid, it will still be removed from the dictionary.
	 * It shouldn’t.
	 * We leave it as-is because these methods are not public. */
	
	mutating func getParsedAndRemove<O : _Object>(_ key: Key, _ originalDictionary: [String: Any?]) throws -> O {
		let dic: [String: Any?] = try getAndRemove(
			key,
			notFoundError: Err.missingProperty(key/*, objectDictionary: originalDictionary*/),
			wrongTypeError: Err.propertyValueIsNotDictionary(propertyName: key/*, objectDictionary: originalDictionary*/)
		)
		return try O.init(dictionary: dic, parentPropertyName: key)
	}
	
	mutating func getParsedIfExistsAndRemove<O : _Object>(_ key: Key, _ originalDictionary: [String: Any?]) throws -> O? {
		guard let dic: [String: Any?] = try getIfExistsAndRemove(
			key,
			wrongTypeError: Err.propertyValueIsNotDictionary(propertyName: key/*, objectDictionary: originalDictionary*/)
		) else {
			return nil
		}
		return try O.init(dictionary: dic, parentPropertyName: key)
	}
	
}
