import Foundation
#if canImport(System)
import System
#else
import SystemPackage
#endif



public protocol BuildPhase {
	
	init(root: FilePath, inputs: [FilePath], arguments: [String: Any]) throws
	
	var outputs: [FilePath] {get}
	
	var canBeSkipped: Bool {get async throws}
	/**
	 - Returns: The paths of the files actually produced. */
	func execute() async throws -> [FilePath]
	
}
