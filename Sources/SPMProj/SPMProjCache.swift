import Foundation

import Basics
import PackageGraph
import TSCBasic
import Workspace



public class SPMProjCache {
	
	public init() {
	}
	
	public func getProj(for url: URL, workspaceRoot: URL? = nil) throws -> SPMProj {
		let cacheKey = Key(rootURL: url)
		if let cached = storage[cacheKey] {
			return try cached.get()
		}
		let ret = Result<SPMProj, Error>{ try SPMProj(url: url, workspaceRoot: workspaceRoot) }
		storage[cacheKey] = ret
		return try ret.get()
	}
	
	var storage = [Key: Result<SPMProj, Error>]()
	
	struct Key : Hashable {
		public var rootURL: URL
	}
	
}
