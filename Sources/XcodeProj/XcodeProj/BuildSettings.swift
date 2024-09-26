import Foundation

import GlobalConfModule
import SafeGlobal

import Utils



/**
 Represents a “level” of build settings.
 
 This can either be an xcconfig file, or the project settings, or the settings of a target.*/
public struct BuildSettings {
	
	@SafeGlobal
	private static var cachedDeveloperDir: String?
	
	/* Let’s get the developer dir!
	 * Our algo will be:
	 *    - If we have a cached version, use it;
	 *    - If DEVELOPER_DIR env var is defined, use that;
	 *    - Otherwise try and get the path w/ xcode-select. */
	public static func getDeveloperDir() throws -> String {
		if let cachedDeveloperDir {
			return cachedDeveloperDir
		}
		
		if let p = getenv("DEVELOPER_DIR") {
			let ret = String(cString: p)
			cachedDeveloperDir = ret
			return ret
		}
		
		let p = Process()
		/* If the executable does not exist, the app crashes w/ an unhandled exception.
		 * We assume /usr/bin/env will always exist. */
		p.executableURL = URL(fileURLWithPath: "/usr/bin/env")
		p.arguments = ["/usr/bin/xcode-select", "-p"]
		
		p.standardInput = nil
		p.standardError = nil
		
		let pipe = Pipe()
		p.standardOutput = pipe
		
		p.launch()
		p.waitUntilExit()
		guard p.terminationReason == .exit, p.terminationStatus == 0 else {
			throw Err.internalError(.cannotGetDeveloperDir)
		}
		
		let outputData: Data?
		if #available(OSX 10.15.4, *) {
			outputData = try Result{ try pipe.fileHandleForReading.readToEnd() }
				.mapErrorAndGet{ _ in Err.internalError(.cannotGetDeveloperDir) }
		} else {
			/* Note: This can throw an (uncatchable objc) exception! */
			outputData = pipe.fileHandleForReading.readDataToEndOfFile()
		}
		let outputString = try outputData.flatMap{ String(data: $0, encoding: .utf8) }
			.get(orThrow: Err.internalError(.cannotGetDeveloperDir))
			.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !outputString.isEmpty else {
			throw Err.internalError(.cannotGetDeveloperDir)
		}
		cachedDeveloperDir = outputString
		return outputString
	}
	
	public static func standardDefaultSettings(xcodeprojURL: URL) throws -> BuildSettings {
		return try BuildSettings(rawBuildSettings: standardDefaultSettingsAsDictionary(xcodeprojURL: xcodeprojURL))
	}
	
	/**
	 Return the standard default build settings that one can use to resolve the build settings in a pbxproj.
	 
	 For the time being only a very limited set of variables are returned.
	 We might return more later. */
	public static func standardDefaultSettingsAsDictionary(xcodeprojURL: URL) throws -> [String: String] {
		let projectDirPath = xcodeprojURL.deletingLastPathComponent().path
		return [
			"HOME": FileManager.default.homeDirectoryForCurrentUser.path,
			
			"DEVELOPER_DIR": try getDeveloperDir(),
			
			/* <https://stackoverflow.com/a/43751741> */
			"PROJECT_DIR": projectDirPath,
			"PROJECT_FILE_PATH": xcodeprojURL.path,
			"PROJECT_NAME": xcodeprojURL.deletingPathExtension().lastPathComponent,
			"SRCROOT": projectDirPath,
			"SOURCE_ROOT": projectDirPath /* Unofficial alias of SRCROOT */
		]
	}
	
	/**
	 Return the standard default build settings that one can use to resolve the build settings _and the paths_ in a pbxproj.
	 
	 For the time being only a very limited set of variables are returned.
	 We might return more later.
	 
	 The dictionary is the same as the standard default settings, but with the following keys added: `SDKROOT` and `BUILT_PRODUCTS_DIR`.
	 
	 The default values for these keys are:
	 ```
	 - SDKROOT            -> /tmp/__DUMMY_SDK__;
	 - BUILT_PRODUCTS_DIR -> /tmp/__DUMMY_BUILT_PRODUCT_DIR__.
	 ``` */
	public static func standardDefaultSettingsForResolvingPaths(xcodeprojURL: URL) throws -> BuildSettings {
		return try BuildSettings(rawBuildSettings: standardDefaultSettingsForResolvingPathsAsDictionary(xcodeprojURL: xcodeprojURL))
	}
	
	public static func standardDefaultSettingsForResolvingPathsAsDictionary(xcodeprojURL: URL) throws -> [String: String] {
		var ret = try standardDefaultSettingsAsDictionary(xcodeprojURL: xcodeprojURL)
		ret["SDKROOT"]            = "/tmp/__DUMMY_SDK__"
		ret["BUILT_PRODUCTS_DIR"] = "/tmp/__DUMMY_BUILT_PRODUCT_DIR__"
		return ret
	}
	
	public var settings: [BuildSettingRef]
	
	public init() {
		settings = []
	}
	
	public init(rawBuildSettings: [String: Any], location: BuildSetting.Location = .none, allowCommaSeparatorForParameters: Bool = false) {
		settings = rawBuildSettings.map{ BuildSettingRef(BuildSetting(laxSerializedKey: $0.key, value: $0.value, location: location, allowCommaSeparatorForParameters: allowCommaSeparatorForParameters)) }
	}
	
	public init(xcconfigURL url: URL, sourceConfig: XCBuildConfiguration?, failIfFileDoesNotExist: Bool = true, allowCommaSeparatorForParameters: Bool = false, allowSpacesAfterSharp: Bool = false, allowNoSpacesAfterInclude: Bool = false) throws {
		try self.init(xcconfigURL: url, sourceConfig: sourceConfig, failIfFileDoesNotExist: failIfFileDoesNotExist, seenFiles: [], allowCommaSeparatorForParameters: allowCommaSeparatorForParameters, allowSpacesAfterSharp: allowSpacesAfterSharp, allowNoSpacesAfterInclude: allowNoSpacesAfterInclude)
	}
	
	private init(xcconfigURL url: URL, sourceConfig: XCBuildConfiguration?, failIfFileDoesNotExist: Bool, seenFiles: Set<URL>, allowCommaSeparatorForParameters: Bool, allowSpacesAfterSharp: Bool, allowNoSpacesAfterInclude: Bool) throws {
		let xcconfig = try XCConfig(url: url, failIfFileDoesNotExist: failIfFileDoesNotExist, allowCommaSeparatorForParameters: allowCommaSeparatorForParameters, allowSpacesAfterSharp: allowSpacesAfterSharp, allowNoSpacesAfterInclude: allowNoSpacesAfterInclude)
		let seenFiles = seenFiles.union([url.absoluteURL])
		let xcconfigRef = XCConfigRef(xcconfig)
		
		settings = try xcconfig.sortedLines.flatMap{ lineAndID -> [BuildSettingRef] in
			let (lineID, line) = lineAndID
			switch line {
				case .void:
					return []
					
				case .include(path: let path, isOptional: let isOptional, prefix: _, postSharp: _, postDirective: _, suffix: _):
					guard !path.isEmpty else {
						/* An empty path is ignored by Xcode with a warning AFAICT (Xcode 12.0.1 (12A7300)). */
						Conf.logger?.warning("Trying to import empty file path from \(url.path).")
						return []
					}
					
					let urlToImport = try xcconfig.urlFor(importPath: path)
					if !seenFiles.contains(urlToImport.absoluteURL) {
						let importedConfig = try BuildSettings(xcconfigURL: urlToImport, sourceConfig: sourceConfig, failIfFileDoesNotExist: !isOptional, seenFiles: seenFiles, allowCommaSeparatorForParameters: allowCommaSeparatorForParameters, allowSpacesAfterSharp: allowSpacesAfterSharp, allowNoSpacesAfterInclude: allowNoSpacesAfterInclude)
						return importedConfig.settings
					} else {
						Conf.logger?.warning("Skipping include of \(urlToImport.absoluteString) to avoid cycling dependency from \(url.path).")
						return []
					}
					
				case .value(key: let key, value: let value, prefix: _, equalSign: _, suffix: _):
					return [BuildSettingRef(BuildSetting(key: key, value: value, location: .xcconfigFile(xcconfigRef, lineID: lineID, for: sourceConfig)))]
			}
		}
	}
	
	/**
	 Returns the build settings flattened as a dictionary.
	 No variable resolution is done. */
	public var flattened: [String: String] {
		var ret = [String: String]()
		for settingRef in settings {
			let setting = settingRef.value
			ret[setting.key.serialized] = setting.stringValue
		}
		return ret
	}
	
}


public typealias BuildSettingsRef = Ref<BuildSettings>
