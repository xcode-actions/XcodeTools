import Foundation

@preconcurrency import PackageGraph



/**
 Represent an SPM target.
 
 This is Hashable.
 Two SPMTargets are considered equal iif their names and sources root are equal. */
public struct SPMTarget : Sendable {
	
	public var name: String {
		resolvedModules.name
	}
	
	public var sourcesRoot: URL {
		resolvedModules.sources.root.asURL
	}
	
	public var sourcesContainsObjCFiles: Bool {
		resolvedModules.sources.containsObjcFiles
	}
	
	public var sources: [URL] {
		resolvedModules.sources.paths.map(\.asURL)
	}
	
	public var resources: [URL] {
		resolvedModules.underlying.resources.map(\.path.asURL)
	}
	
	public var others: [URL] {
		resolvedModules.underlying.others.map(\.asURL)
	}
	
	public var dependencies: [SPMTarget] {
		resolvedModules.dependencies.flatMap{ dep in
			switch dep {
				case .module(let module, _):   return [module]
				case .product(let product, _): return Array(product.modules)
			}
		}.map(Self.init)
	}
	
	public var recursiveDependencies: [SPMTarget] {
		get throws {
			try resolvedModules.recursiveModuleDependencies().map(Self.init)
		}
	}
	
	internal init(resolvedTarget: ResolvedModule) {
		self.resolvedModules = resolvedTarget
	}
	
	internal let resolvedModules: ResolvedModule
	
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
