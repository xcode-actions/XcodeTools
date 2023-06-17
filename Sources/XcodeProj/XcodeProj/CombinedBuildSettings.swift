import CoreData
import Foundation

import Utils



/** Represents multiple build settings levels combined. */
public struct CombinedBuildSettings {
	
	public static func convenienceSort(_ s1: CombinedBuildSettings, _ s2: CombinedBuildSettings) -> Bool {
		let targetName1 = s1.targetName ?? ""
		let targetName2 = s2.targetName ?? ""
		let configName1 = s1.configurationName
		let configName2 = s2.configurationName
		if targetName1 < targetName2 {return true}
		if targetName1 > targetName2 {return false}
		return configName1 < configName2
	}
	
	public struct ResolvedValue {
		
		public var value: String
		/**
		 The build settings that were used to resolve the value.
		 
		 The _last_ setting will be the most significant.
		 Changing the value of this setting to something that does not contain any variable
		 will effectively change the resolved value of the setting to that.
		 The new resolved value will then only have one source: the setting.
		 
		 The sources can be empty if the resolved value was not resolved using any setting.
		 This can happen if you resolve a string without a setting context or if you try and resolve a setting key which does not have a value. */
		public var sources: [BuildSettingRef]
		
		internal init() {
			self.value = ""
			self.sources = []
		}
		
		internal init(value: String, sources: [BuildSettingRef]) {
			self.value = value
			self.sources = sources
		}
		
	}
	
	/** `nil` if representing build settings of the project. */
	public var targetName: String?
	public var configurationName: String
	
	/**
	 The PBXTarget for which the build settings are.
	 `nil` if representing the build settings of the project. */
	public var target: PBXTarget?
	
	/**
	 The main build configuration for the combined build settings.
	 
	 Changing this configuration for a given key will change the most significant source of the resolved value for this key. */
	public var configuration: XCBuildConfiguration
	
	/**
	 The first level is the deepest (xcconfig project level if it exists).
	 
	 - Note: The array should maybe also contain the source of the build settings.
	 Especially if we want to implement modifying a build setting later. */
	public var buildSettingsLevels: [BuildSettingsRef]
	
	public var buildSettings: [BuildSettingRef] {
		return buildSettingsLevels.flatMap{ $0.value.settings }
	}
	
	/**
	 Returns all the combined build settings for all the targets in the project.
	 
	 - Note: The xcodeproj URL is required because some paths can be relative to the xcodeproj path. */
	public static func allCombinedBuildSettingsForTargets(of project: PBXProject, xcodeprojURL: URL, defaultBuildSettings: BuildSettingsRef) throws -> [CombinedBuildSettings] {
		let targets = try project.getTargets()
		
		let projectSettingsPerConfigName = try allCombinedBuildSettings(for: project.getBuildConfigurations(), targetAndProjectSettingsPerConfigName: nil, xcodeprojURL: xcodeprojURL, defaultBuildSettings: defaultBuildSettings)
			.mapValues{ $0.buildSettingsLevels }
		
		return try targets.flatMap{ target -> [CombinedBuildSettings] in
			return try Array(allCombinedBuildSettings(for: try target.getBuildConfigurations(), targetAndProjectSettingsPerConfigName: (target, projectSettingsPerConfigName), xcodeprojURL: xcodeprojURL, defaultBuildSettings: defaultBuildSettings).values)
		}
	}
	
	public static func allCombinedBuildSettingsForProject(_ project: PBXProject, xcodeprojURL: URL, defaultBuildSettings: BuildSettingsRef) throws -> [CombinedBuildSettings] {
		let projectSettingsPerConfigName = try allCombinedBuildSettings(for: project.getBuildConfigurations(), targetAndProjectSettingsPerConfigName: nil, xcodeprojURL: xcodeprojURL, defaultBuildSettings: defaultBuildSettings)
		return Array(projectSettingsPerConfigName.values)
	}
	
	/**
	 Returns a dictionary whose keys are the configuration names and values are the build settings.
	 
	 - Note: The xcodeproj URL is required because some paths can be relative to the xcodeproj path. */
	static func allCombinedBuildSettings(for configurations: [XCBuildConfiguration], targetAndProjectSettingsPerConfigName: (PBXTarget, [String: [BuildSettingsRef]])?, xcodeprojURL: URL, defaultBuildSettings: BuildSettingsRef) throws -> [String: CombinedBuildSettings] {
		let settings: [(String, CombinedBuildSettings)] = try configurations.map{ configuration in
			let name = try configuration.getName()
			let targetAndProjectSettings: (PBXTarget, [BuildSettingsRef])? = try targetAndProjectSettingsPerConfigName.flatMap{ targetAndProjectSettingsPerConfigName in
				let (target, projectSettingsPerConfigName) = targetAndProjectSettingsPerConfigName
				guard let projectSettings = projectSettingsPerConfigName[name] else {
					throw Err.invalidPBXProjObjectGraph(.targetHasConfigurationNameProjectDoesNot(configName: name), objectID: target.xcID)
				}
				return (target, projectSettings)
			}
			return (name, try CombinedBuildSettings(configuration: configuration, targetAndProjectSettings: targetAndProjectSettings, xcodeprojURL: xcodeprojURL, defaultBuildSettings: defaultBuildSettings))
		}
		return try Dictionary(settings, uniquingKeysWith: { (current, new) in
			throw Err.invalidPBXProjObjectGraph(.atLeastTwoConfigurationsHaveSameName, objectID: nil)
		})
	}
	
	init(configuration config: XCBuildConfiguration, targetAndProjectSettings: (PBXTarget, [BuildSettingsRef])?, xcodeprojURL: URL, defaultBuildSettings: BuildSettingsRef) throws {
		let configName = try config.getName()
		configuration = config
		configurationName = configName
		
		var buildSettingsLevelsBuilding = [defaultBuildSettings]
		
		if let (lTarget, projectSettings) = targetAndProjectSettings {
			let name = try lTarget.getName()
			target = lTarget
			targetName = name
			buildSettingsLevelsBuilding.append(contentsOf: projectSettings)
		} else {
			target = nil
			targetName = nil
		}
		
		if let baseConfigurationReference = config.baseConfigurationReference {
			guard baseConfigurationReference.xcLanguageSpecificationIdentifier == "text.xcconfig" || baseConfigurationReference.lastKnownFileType == "text.xcconfig" else {
				throw Err.invalidPBXProjObjectGraph(.baseConfigurationReferenceIsNotTextXCConfig(configurationID: configuration.xcID), objectID: baseConfigurationReference.xcID)
			}
			let url = try baseConfigurationReference.resolvedPathAsURL(xcodeprojURL: xcodeprojURL, variables: BuildSettings.standardDefaultSettingsForResolvingPathsAsDictionary(xcodeprojURL: xcodeprojURL))
			let config = try BuildSettingsRef(BuildSettings(xcconfigURL: url, sourceConfig: config))
			buildSettingsLevelsBuilding.append(config)
		}
		
		let rawBuildSettings = try configuration.getRawBuildSettings()
		let buildSettings = BuildSettingsRef(BuildSettings(rawBuildSettings: rawBuildSettings, location: .xcconfiguration(config)))
		buildSettingsLevelsBuilding.append(buildSettings)
		
		buildSettingsLevels = buildSettingsLevelsBuilding
	}
	
	public init(target: PBXTarget? = nil, targetName: String? = nil, configuration: XCBuildConfiguration, configurationName: String, buildSettingsLevels: [BuildSettingsRef]) {
		self.target = target
		self.targetName = targetName
		self.configuration = configuration
		self.configurationName = configurationName
		self.buildSettingsLevels = buildSettingsLevels
	}
	
	public subscript(_ key: String) -> String {
		return self[BuildSettingKey(laxSerializedKey: key)]
	}
	
	/**
	 Returns the resolved value that matches the given settings key.
	 
	 This method cannot fail and returns a non-optional because if a variable does not have a value (does not exist), its value is set to "".
	 
	 A build setting value could either be a String, or an array of Strings.
	 For now, if we encounter an array, we “convert” it to a String.
	 The conversion is simply the concatenation of the String values, separated by a space.
	 That’s all.
	 And yes, you can loose info if a element contains a space, but my testing shows this is how Xcode does it:
	 in an array, for an element to be able to contains a space, it MUST be double or simple quoted.
	 
	 If a build setting have an unknown type (neither a String nor an array of Strings), we return en empty String for this value. */
	public subscript(_ key: BuildSettingKey) -> String {
		return resolvedValue(for: key)?.value ?? ""
	}
	
	/**
	 Try and resolve the value for the given key.
	 Returns `nil` if the key does not exist in the settings.
	 
	 If any, the resolved value you get from this method will always contain at least one source. */
	public func resolvedValue(for key: BuildSettingKey) -> ResolvedValue? {
		/* We want to retrieve an array of (Int, BuildSetting), where the Int represents the level from which the build setting is from.
		 * I did this because I though I’d need this, but I actually won’t.
		 * Note that the pre-Xcode-10 way of resolving variables needed this I think! <https://stackoverflow.com/a/50731052>
		 * Basically before Xcode 10 I think the equivalent BuildSettings internal structure in Xcode held its settings as a dictionary
		 * instead of an array of BuildSetting, which prevented it from doing the smarter resolution it now has. */
		let searchedSettings = buildSettingsLevels.enumerated().flatMap{ elementAndOffset in elementAndOffset.element.value.settings.map{ (level: elementAndOffset.offset, setting: $0) } }
#warning("TODO: Implement variable conditionals…")
		let settingsWhoseKeyMatch = searchedSettings.filter{ $0.setting.value.key.key == key.key }
		
		guard !settingsWhoseKeyMatch.isEmpty else {
			return nil
		}
		
		var resolvedValue = ResolvedValue()
		var currentlyResolvedValues = [key.key: resolvedValue]
		for settingRef in settingsWhoseKeyMatch.map({ $0.setting }) {
			let scanner = Scanner(forParsing: settingRef.value.stringValue)
			resolvedValue = resolveVariables(scanner: scanner, currentlyResolvedValues: &currentlyResolvedValues, inheritedVariableName: key.key)
			resolvedValue.sources.append(settingRef)
			currentlyResolvedValues[key.key] = resolvedValue
		}
		
		assert(!resolvedValue.sources.isEmpty)
		return resolvedValue
	}
	
	public func infoPlistURL(xcodeprojURL: URL) -> URL? {
		guard let path = resolvedValue(for: BuildSettingKey(key: "INFOPLIST_FILE"))?.value else {
			return nil
		}
		return URL(fileURLWithPath: path, isDirectory: false, relativeTo: xcodeprojURL.deletingLastPathComponent())
	}
	
	public func infoPlistRaw(xcodeprojURL: URL) throws -> [String: Any]? {
		guard let plistURL = infoPlistURL(xcodeprojURL: xcodeprojURL) else {
			return nil
		}
		let plistData = try Result{ try Data(contentsOf: plistURL) }.mapErrorAndGet{ Err.cannotReadFile(plistURL, $0) }
		let deserializedPlist = try Result{ try PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) }
			.mapErrorAndGet{ Err.infoPlistParseError(.plistParseError($0)) }
		guard let deserializedPlistObject = deserializedPlist as? [String: Any] else {
			throw Err.infoPlistParseError(.deserializedPlistHasInvalidType)
		}
		return deserializedPlistObject
	}
	
	/**
	 Get the Info.plist if any, then deserialize it and resolved the variables.
	 
	 - Note: Does _not_ resolve localized strings. */
	public func infoPlistResolved(xcodeprojURL: URL) throws -> [String: Any]? {
		func resolveVariablesGeneric<T>(_ object: T) -> T {
			switch object {
				case let string as String:            return resolveVariables(in: string).value as! T
				case let array as [Any]:              return array.map(resolveVariablesGeneric) as! T
				case let dictionary as [String: Any]: return dictionary.mapValues(resolveVariablesGeneric) as! T
				default:                              return object
			}
		}
		return try infoPlistRaw(xcodeprojURL: xcodeprojURL).flatMap(resolveVariablesGeneric)
	}
	
	public func resolveVariables(in string: String) -> ResolvedValue {
		let scanner = Scanner(forParsing: string)
		var currentlyResolvedValues = [String: ResolvedValue]()
		return resolveVariables(scanner: scanner, currentlyResolvedValues: &currentlyResolvedValues)
	}
	
	/**
	 Resolve the variables in the given string (via a Scanner).
	 
	 `varEndChars` contains the characters that should end the parsing of the variable (for embedded variables).
	 Always call with an empty string first to parse the whole string.
	 
	 Example: `$(VAR1_${VAR2})`, when parser is called first, the value will be an empty string, then “`)`” then “`}`”.
	 
	 `inheritedVariableName` is given to resolve the “inherited” variable name. */
	private func resolveVariables(scanner: Scanner, currentlyResolvedValues: inout [String: ResolvedValue], inheritedVariableName: String? = nil, varEndChars: String = "") -> ResolvedValue {
		var result = ""
		var sources = [BuildSettingRef]()
		
		/** Returns `true` if a potential variable start has been found. */
		func parseUpToStartOfVariableIncludingDollar() -> Bool {
			result.append(scanner.scanUpToCharacters(from: CharacterSet(charactersIn: "$" + varEndChars)) ?? "")
			
			if scanner.scanString("$") != nil {
				/* If we have found a dollar sign, we have found the potential start of a variable.
				 * We return true. */
				return true
			}
			
			/* Now we still have to parse a potential stray character (the end char or something else,
			 * if we just parsed a variable without parenthesis, in which case we don’t want to parse it,
			 * that’s why we come back to previous location is scanned char is not in varEndChars). */
			let scanIndex = scanner.currentIndex
			if let c = scanner.scanCharacter(), !varEndChars.contains(c) {
				scanner.currentIndex = scanIndex
			}
			return false
		}
		
		while parseUpToStartOfVariableIncludingDollar() {
			/* We might have reached the start of a variable.
			 * Let’s verify that.
			 * AFAICT (from the tests in the project 1 in the tests data), the only way to _not_ have a variable start is to parse a dollar here. */
			guard scanner.scanString("$") == nil else {
				result.append("$")
				continue
			}
			
			let mustExist: Bool
			let rawVariableName: String
			if scanner.scanString("(") != nil {
				let resolved = resolveVariables(scanner: scanner, currentlyResolvedValues: &currentlyResolvedValues, varEndChars: ")")
				sources.append(contentsOf: resolved.sources)
				rawVariableName = resolved.value
				mustExist = false
			} else if scanner.scanString("{") != nil {
				let resolved = resolveVariables(scanner: scanner, currentlyResolvedValues: &currentlyResolvedValues, varEndChars: "}")
				sources.append(contentsOf: resolved.sources)
				rawVariableName = resolved.value
				mustExist = false
			} else {
				rawVariableName = scanner.scanCharacters(from: BuildSettingKey.charactersValidInVariableName) ?? ""
				mustExist = true
			}
			
			let variableName: String
			if rawVariableName == "inherited" {variableName = inheritedVariableName ?? ""}
			else                              {variableName = rawVariableName}
			
			let resolvedOptional = currentlyResolvedValues[variableName] ?? resolvedValue(for: BuildSettingKey(key: variableName, parameters: []))
			let resolved: ResolvedValue
			if let r = resolvedOptional {resolved = r}
			else if mustExist           {resolved = ResolvedValue(value: "$" + variableName, sources: [])}
			else                        {resolved = ResolvedValue(value: "", sources: [])}
			
			currentlyResolvedValues[variableName] = resolved
			sources.append(contentsOf: resolved.sources)
			result.append(resolved.value)
		}
		
		return ResolvedValue(value: result, sources: sources)
	}
	
}
