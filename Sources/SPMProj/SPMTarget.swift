import Foundation

import PackageGraph



/**
 Represent an SPM target.
 
 This is Hashable.
 Two SPMTargets are considered equal iif their names and sources root are equal. */
public struct SPMTarget {
	
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
	
	public var dependencies: [SPMTarget] {
		resolvedTarget.dependencies.flatMap{ dep in
			switch dep {
				case .target(let target, _):   return [target]
				case .product(let product, _): return product.targets
			}
		}.map(Self.init)
	}
	
	public var recursiveDependencies: [SPMTarget] {
		get throws {
			try resolvedTarget.recursiveTargetDependencies().map(Self.init)
		}
	}
	
	internal init(resolvedTarget: ResolvedTarget) {
		self.resolvedTarget = resolvedTarget
	}
	
	internal let resolvedTarget: ResolvedTarget
	
}


extension SPMTarget : Hashable {
	
	public static func ==(_ lhs: SPMTarget, _ rhs: SPMTarget) -> Bool {
		return lhs.name == rhs.name && lhs.sourcesRoot == rhs.sourcesRoot
	}
	
	public func hash(into hasher: inout Hasher) {
		hasher.combine(name)
		hasher.combine(sourcesRoot)
	}
	
}
