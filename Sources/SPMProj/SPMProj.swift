import Foundation

import Basics
import PackageGraph
import TSCBasic
import Workspace



/* Some libSPM help:
 *  <https://github.com/apple/swift-package-manager/blob/swift-5.8-RELEASE/Examples/package-info/Sources/package-info/example.swift>.
 *
 * **IMPORTANT**:
 * The `swift-package-manager` dependency might not succeed in loading the packages if the Swift’s compiler version on the system is not the same as the dependency’s version.
 * The reason for this is `swift-package-manager` has to call the compiler to “parse” the `Package.swift` file which describe the package.
 * If the output of the compiler changed between versions, the parsing output won’t be recognized.
 * E.g. when building XcodeTools w/ `swift-package-manager` version `0.50800.0` on macOS 14.0 Beta with Xcode 15.0 beta, the packages fail to load. */
public struct SPMProj {
	
	public let rootURL: URL
	public let projectManifestURL: URL
	
	public var targets: [SPMTarget] {
#warning("TODO: platform selection…")
		return packageGraph.reachableTargets.filter{ packageGraph.isInRootPackages($0, satisfying: .init(platform: .macOS)) }.map(SPMTarget.init)
	}
	
	public init(path: String? = nil) throws {
		try self.init(url: path.flatMap{ URL(fileURLWithPath: $0) })
	}
	
	public init(url: URL? = nil, workspaceRoot: URL? = nil) throws {
		self.rootURL = url ?? URL(fileURLWithPath: ".")
		self.projectManifestURL = rootURL.appendingPathComponent("Package.swift")
		
		let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
		let workspace = try Workspace(forRootPackage: AbsolutePath(validating: (workspaceRoot ?? tempDir).path))
		
		let observability = ObservabilitySystem{ scope, diag in
			Conf.logger?.debug("Message from SPM: \(diag)")
		}
		
		self.packageGraph = try workspace.loadPackageGraph(rootPath: AbsolutePath(validating: rootURL.path), observabilityScope: observability.topScope)
		guard packageGraph.rootPackages.count == 1 else {
			throw Err.cannotLoadPackage(rootURL)
		}
	}
	
	internal var packageGraph: PackageGraph
	internal var resolvedPackage: ResolvedPackage {
		packageGraph.rootPackages.first!
	}
	
}
