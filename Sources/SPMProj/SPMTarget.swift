import Foundation

import PackageGraph



public struct SPMTarget : Hashable {
	
	public var name: String {
		resolvedTarget.name
	}
	
	public var sourcesRoot: URL {
		resolvedTarget.sources.root.asURL
	}
	
	public var sourcesContainsObjCFiles: Bool {
		resolvedTarget.sources.containsObjcFiles
	}
	
	public var sources: [URL] {
		resolvedTarget.sources.paths.map(\.asURL)
	}
	
	public var resources: [URL] {
		resolvedTarget.underlyingTarget.resources.map(\.path.asURL)
	}
	
	public var others: [URL] {
		resolvedTarget.underlyingTarget.others.map(\.asURL)
	}
	
	internal init(resolvedTarget: ResolvedTarget) {
		self.resolvedTarget = resolvedTarget
	}
	
	internal let resolvedTarget: ResolvedTarget
	
}
