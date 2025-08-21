import Foundation

import Basics
import GlobalConfModule
@preconcurrency import PackageGraph
import TSCBasic
import Workspace



/* Some libSPM help:
 *  <https://github.com/apple/swift-package-manager/blob/swift-5.8-RELEASE/Examples/package-info/Sources/package-info/example.swift>.
 *
 * **IMPORTANT**:
 * The `swift-package-manager` dependency might not succeed in loading the packages if the Swift’s compiler version on the system is not the same as the dependency’s version.
 * The reason for this is `swift-package-manager` has to call the compiler to “parse” the `Package.swift` file which describe the package.
 * If the output of the compiler changed between versions, the parsing output won’t be recognized.
 * E.g. using XcodeTools built w/ `swift-package-manager` version `0.50800.0` on macOS 14.0 Beta with the Xcode 15.0 beta toolchain will not work (packages will fail to load). */

/**
 The description of an SPM project.
 
 This struct is Hashable.
 Two SPMProj are considered equal if their root and project manifest URLs are equal. */
public struct SPMProj : Sendable {
	
	public let rootURL: URL
	public let projectManifestURL: URL
	
	public init(path: String? = nil) async throws {
		try await self.init(url: path.flatMap{ URL(fileURLWithPath: $0) })
	}
	
	public init(url: URL? = nil, workspaceRoot: URL? = nil) async throws {
		self.rootURL = url ?? URL(fileURLWithPath: ".")
		self.projectManifestURL = rootURL.appendingPathComponent("Package.swift")
		
		let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
		let workspace = try Workspace(forRootPackage: AbsolutePath(validating: (workspaceRoot ?? tempDir).path))
		
		let observability = ObservabilitySystem{ scope, diag in
			Conf.logger?.debug("Message from SPM: \(diag)")
		}
		
		self.modulesGraph = try await workspace.loadPackageGraph(rootPath: AbsolutePath(validating: rootURL.path), observabilityScope: observability.topScope)
		guard modulesGraph.rootPackages.count == 1 else {
			throw Err.cannotLoadPackage(rootURL)
		}
	}
	
	public var targets: [SPMTarget] {
#warning("TODO: platform selection…")
		return modulesGraph.reachableModules.filter{ modulesGraph.isInRootPackages($0, satisfying: .init(platform: .macOS)) }.map(SPMTarget.init)
	}
	
	internal var modulesGraph: ModulesGraph
	internal var resolvedPackage: ResolvedPackage {
		modulesGraph.rootPackages.first!
	}
	
}


extension SPMProj : Hashable {
	
	public static func ==(_ lhs: SPMProj, _ rhs: SPMProj) -> Bool {
		return lhs.rootURL == rhs.rootURL && lhs.projectManifestURL == rhs.projectManifestURL
	}
	
	public func hash(into hasher: inout Hasher) {
		hasher.combine(rootURL)
		hasher.combine(projectManifestURL)
	}
	
}
