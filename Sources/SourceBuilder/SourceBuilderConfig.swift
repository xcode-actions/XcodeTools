import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

import GlobalConfModule
import Logging



public extension ConfKeys {
	/* URLRequestOperation conf namespace declaration. */
	struct SourceBuilder {}
	var sourceBuilder: SourceBuilder {SourceBuilder()}
}


extension ConfKeys.SourceBuilder {
	
	#declareConfKey("logger",      Logging.Logger?.self, defaultValue: .init(label: "com.xcode-actions.SourceBuilder"))
	
	#declareConfKey("fileManager", FileManager    .self, unsafeNonIsolated: true, defaultValue: .default)
	#declareConfKey("urlSession",  URLSession     .self,                          defaultValue: .shared)
	
	#declareConfKey("buildPhases", BuildPhases    .self,                          defaultValue: .init())
	
}


extension Conf {
	
	#declareConfAccessor(\.sourceBuilder.logger, Logging.Logger?.self)
	
	/* We cannot use the declareConfAccessor macro for the fileManager as the value is not Sendable. */
	internal static var fileManager: FileManager {Conf[\.sourceBuilder.fileManager].value}
	#declareConfAccessor(\.sourceBuilder.urlSession,  URLSession .self)
	
	#declareConfAccessor(\.sourceBuilder.buildPhases, BuildPhases.self)
	
}


public struct BuildPhases : Sendable {
	
	public mutating func registerPhase(name: String, type: BuildPhase.Type) -> Bool {
		guard registeredBuildPhases[name] == nil else {
			Conf.logger?.error("Build phase “\(name)” is already registered. Ignoring new registration.")
			return false
		}
		registeredBuildPhases[name] = type
		return true
	}
	
	private var registeredBuildPhases: [String: BuildPhase.Type] = [:]
	
}
