import Foundation



/**
 Represent a build setting key (string and parameters).
 
 For example, for the following config: “`MY_CONFIG[sdk=*][arch=*]`”, the `BuildSettingKey` would be:
 ```
 key = "MY_CONFIG"
 parameters = [("sdk", "*"), ("arch", "*")]
 ```
 
 - Important:
 No validation is done on the parameters, nor the key, but you can validate whether the resulting object is valid later. */
public struct BuildSettingKey : Hashable {
	
	public struct BuildSettingKeyParam : Hashable {
		
		public var key: String
		public var value: String
		
		var nextParamSeparatedByComma: Bool
		
		public func hash(into hasher: inout Hasher) {
			hasher.combine(key)
			hasher.combine(value)
		}
		
		public static func ==(_ lhs: BuildSettingKeyParam, _ rhs: BuildSettingKeyParam) -> Bool {
			return (
				lhs.key == rhs.key &&
				lhs.value == rhs.value
			)
		}
		
	}
	
	public var key: String
	public var parameters: [BuildSettingKeyParam]
	
	var garbage: String
	
	public init(laxSerializedKey serializedKey: String, allowCommaSeparatorForParameters: Bool = false) {
		let scanner = Scanner(forParsing: serializedKey)
		key = scanner.scanUpToString("[") ?? ""
		parameters = BuildSettingKey.parseSettingParams(scanner: scanner, allowCommaSeparator: allowCommaSeparatorForParameters)
		garbage = scanner.scanUpToCharacters(from: CharacterSet()) ?? ""
		if !garbage.isEmpty {
			Conf.logger?.warning("Got build setting key which seems invalid. Got garbage: “\(garbage)”. Raw key is: “\(serializedKey)”.")
		}
	}
	
	public init(serializedKey: String, allowCommaSeparatorForParameters: Bool = false) throws {
		let scanner = Scanner(forParsing: serializedKey)
		key = scanner.scanUpToString("[") ?? ""
		parameters = BuildSettingKey.parseSettingParams(scanner: scanner, allowCommaSeparator: allowCommaSeparatorForParameters)
		garbage = scanner.scanUpToCharacters(from: CharacterSet()) ?? ""
		guard garbage.isEmpty else {
			throw Err.buildSettingParseError(.unfinishedKey(full: serializedKey, garbage: garbage))
		}
	}
	
	public init(key: String, parameters: [BuildSettingKeyParam] = []) {
		self.key = key
		self.parameters = parameters
		self.garbage = ""
	}
	
	public func isValid(allowGarbage: Bool) -> Bool {
		guard allowGarbage || garbage.isEmpty else {
			return false
		}
		
		guard !key.isEmpty else {
			return false
		}
		guard key.rangeOfCharacter(from: BuildSettingKey.charactersValidInVariableName.inverted, options: .literal) == nil else {
			return false
		}
		guard String(key[key.startIndex]).rangeOfCharacter(from: BuildSettingKey.charactersValidForFirstVariableCharacter.inverted, options: .literal) == nil else {
			return false
		}
		
		for parameter in parameters {
			/* An opening bracket and non-alnum chars seems to be valid at compile time but not in the GUI (Xcode 12.0.1 (12A7300)).
			 * We’ll validate only alphanums in the keys.
			 * In theory the parameter keys should only be known keys from Xcode anyway. */
			guard !parameter.key.isEmpty && parameter.key.rangeOfCharacter(from: CharacterSet.asciiAlphanum.inverted, options: .literal) == nil else {
				return false
			}
			/* An empty value seems to parse correctly, but the meaning is unclear.
			 * We’ll only validate alphanums, stars, commas and equal signs.
			 * We allow the commas and equal signs not to fail validation of xcconfig files written w/ the comma paramter style,
			 * that were parsed w/o the comma allowed.
			 * Here also, the values should only be known values from Xcode. */
			guard parameter.value.rangeOfCharacter(from: CharacterSet.asciiAlphanum.union(CharacterSet(charactersIn: "*,=")).inverted, options: .literal) == nil else {
				return false
			}
		}
		return true
	}
	
	public var serialized: String {
		var isFirst = true
		var sepIsComma = false
		
		let paramString = parameters.reduce("", { curResult, curParam in
			let ret = (
				curResult +
				(!isFirst && !sepIsComma ? "]" : "") +
				(sepIsComma ? "," : "[") +
				curParam.key +
				"=" +
				curParam.value
			)
			isFirst = false
			sepIsComma = curParam.nextParamSeparatedByComma
			return ret
		}) + (parameters.isEmpty ? "" : "]")
		
		return key + paramString + garbage
	}
	
	public func hash(into hasher: inout Hasher) {
		hasher.combine(key)
		hasher.combine(parameters)
	}
	
	public static func ==(_ lhs: BuildSettingKey, _ rhs: BuildSettingKey) -> Bool {
		return (
			lhs.key == rhs.key &&
			lhs.parameters == rhs.parameters
		)
	}
	
	/**
	 Parses the parameter of a setting.
	 
	 Expects a scanner whose location is at the beginning of the parameters (open bracket).
	 Example:
	 ```
	 MY_BUILD_SETTING[skd=*]
	                 ^ scanner location
	 ```
	 
	 At the end of the function, the scanner’s location will be at the end of the parameters (just after the closing bracket).
	 Example:
	 ```
	 MY_BUILD_SETTING[skd=*]
	                        ^ scanner location
	 ```
	 
	 In case of a parsing error, the scanner’s location will be put to the last successful parse location,
	 and all successfully parsed parameters will be returned.
	 Examples:
	 ```
	 MY_BUILD_SETTING[skd=*][this_is_junk
	                        ^ scanner location
	    -> Returned parameters: [("sdk", "*")]
	 MY_BUILD_SETTING[skd=*][arch=*,this_is_junk
	                        ^ scanner location
	    -> Returned parameters: [("sdk", "*")]
	 ```
	 
	 - parameter scanner: A scanner whose location is at the beginning of the parameters.
	 - parameter allowCommaSeparator:
	 <https://pewpewthespells.com/blog/xcconfig_guide.html> says the settings parameters can be separated by a comma, like so: `PARAMETER[sdk=*,arch=*]`.
	 My tests told me it does not work! (12.0 (12A7209))
	 You can reactivate parsing w/ the comma for tests if needed w/ this param. */
	static func parseSettingParams(scanner: Scanner, allowCommaSeparator: Bool) -> [BuildSettingKeyParam] {
		var first = true
		var success = true
		var lastSuccessParseIdx = scanner.currentIndex
		
		var parameters = [BuildSettingKeyParam]()
		var pendingParameters = [BuildSettingKeyParam]()
		while scanner.scanString("[") != nil || (allowCommaSeparator && !first && scanner.scanString(",") != nil) {
			let variantName = scanner.scanUpToString("=") ?? ""
			if scanner.scanString("=") == nil {
				scanner.currentIndex = lastSuccessParseIdx
				return parameters
			}
			
			let variantValue = scanner.scanUpToCharacters(from: CharacterSet(charactersIn: allowCommaSeparator ? ",]" : "]")) ?? ""
			if scanner.scanString("]") != nil {
				parameters.append(contentsOf: pendingParameters)
				parameters.append(BuildSettingKeyParam(key: variantName, value: variantValue, nextParamSeparatedByComma: false))
				lastSuccessParseIdx = scanner.currentIndex
				pendingParameters.removeAll()
				success = true
			} else {
				/* We are either on the comma separator (if allowed) or at the end of the string.
				 * If at the end of the string, this is an error, which will be caugth when we exit the loop and success is not true.
				 * If we’re on the comma separator, we continue the parsing. */
				pendingParameters.append(BuildSettingKeyParam(key: variantName, value: variantValue, nextParamSeparatedByComma: true))
				success = false
			}
			
			first = false
		}
		if !success {
			scanner.currentIndex = lastSuccessParseIdx
		}
		return parameters
	}
	
	static let charactersValidForFirstVariableCharacter = CharacterSet(charactersIn: "_").union(CharacterSet.asciiAlpha)
	static let charactersValidInVariableName = charactersValidForFirstVariableCharacter.union(CharacterSet.asciiNum)
	
}
