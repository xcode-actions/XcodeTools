import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

import Logging



/** A container to hold the properties that can modify the behaviour of the module. */
public enum SourceBuilderConfig {
	
	public static func registerBuildPhase(name: String, type: BuildPhase.Type) -> Bool {
		guard registeredBuildPhases[name] == nil else {
			logger?.error("Build phase “\(name)” is already registered. Ignoring new registration.")
			return false
		}
		registeredBuildPhases[name] = type
		return true
	}
	private static var registeredBuildPhases: [String: BuildPhase.Type] = [
		"download-file": DownloadFilePhase.self,
		"untar": UntarPhase.self
	]
	
	/**
	 The `FileManager` that will be used in ``SourceBuilder``.
	 
	 - Important: This property is not thread-safe. */
	public static var fm: FileManager = .default
	
	@TaskLocal
	public static var urlSession: URLSession = .shared
	
	public static var logger: Logger? = .init(label: "com.xcode-actions.SourceBuilder")
	
}

typealias Conf = SourceBuilderConfig
