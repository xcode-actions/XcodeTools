// swift-tools-version:6.0
import PackageDescription

import Foundation


let swiftSettings: [SwiftSetting] = []
//let swiftSettings: [SwiftSetting] = [.unsafeFlags(["-Xfrontend", "-warn-concurrency", "-Xfrontend", "-enable-actor-data-race-checks"])]


let package = Package(
	name: "XcodeTools",
	platforms: [.macOS(.v13)],
	products: {
		var res = [Product]()
		
		/* ******************* */
		/* *** Executables *** */
		/* ******************* */
		
		/* A launcher for xcode tools binaries (xct-*). */
		res.append(.executable(name: "xct",          targets: ["xct"]))
#if canImport(CoreData)
		res.append(.executable(name: "xct-build",    targets: ["xct-build"]))
		res.append(.executable(name: "xct-gen",      targets: ["xct-gen"]))
		res.append(.executable(name: "xct-pbxproj",  targets: ["xct-pbxproj"]))
		res.append(.executable(name: "xct-versions", targets: ["xct-versions"]))
		/* Obsolete; kept for backwards-compatibility. Will be removed. */
		res.append(.executable(name: "hagvtool",     targets: ["hagvtool"]))
#endif
		
		/* ****************** */
		/* *** Frameworks *** */
		/* ****************** */
		
#if canImport(CoreData)
		res.append(.library(name: "XcodeTools", targets: ["XcodeTools"]))
		res.append(.library(name: "SourceBuilder", targets: ["SourceBuilder"]))
#endif
		/* A lib one can use to manipulate SPM Projects.
		 * Basically a wrapper around swift-package-manager. */
		res.append(.library(name: "SPMProj", targets: ["SPMProj"]))
#if canImport(CoreData)
		/* A lib one can use to manipulate Xcode Projects. */
		res.append(.library(name: "XcodeProj", targets: ["XcodeProj"]))
#endif
		/* Some re-usable utilities. */
		res.append(.library(name: "XCTUtils", targets: ["Utils"]))
		
		return res
	}(),
	dependencies: {
		var res = [Package.Dependency]()
		res.append(.package(url: "https://github.com/apple/swift-argument-parser.git",            from: "1.2.3"))
		res.append(.package(url: "https://github.com/apple/swift-crypto.git",                     "1.0.0"..<"4.0.0"))
		res.append(.package(url: "https://github.com/apple/swift-log.git",                        from: "1.5.2"))
		res.append(.package(url: "https://github.com/apple/swift-package-manager.git",            revision: "swift-6.1.1-RELEASE")) /* Apple does not semver SPM for some reason. */
		res.append(.package(url: "https://github.com/apple/swift-system.git",                     from: "1.6.2"))
		res.append(.package(url: "https://github.com/Frizlab/CollectionConcurrencyKit.git",       from: "0.3.0"))
		res.append(.package(url: "https://github.com/Frizlab/GlobalConfModule.git",               from: "0.4.0"))
		res.append(.package(url: "https://github.com/Frizlab/SafeGlobal.git",                     from: "0.3.0"))
		res.append(.package(url: "https://github.com/Frizlab/UnwrapOrThrow.git",                  from: "1.0.1"))
		res.append(.package(url: "https://github.com/Frizlab/XibLoc.git",                         from: "1.5.1-beta"))
		res.append(.package(url: "https://github.com/xcode-actions/clt-logger.git",               from: "0.5.1"))
		res.append(.package(url: "https://github.com/xcode-actions/stream-reader.git",            from: "3.5.0"))
		res.append(.package(url: "https://github.com/xcode-actions/swift-process-invocation.git", from: "1.2.0"))
		res.append(.package(url: "https://github.com/xcode-actions/swift-signal-handling.git",    from: "1.1.0"))
		return res
	}(),
	targets: {
		var res = [Target]()
		
		/* *********** */
		/* *** xct *** */
		/* *********** */
		
		res.append(.executableTarget(name: "xct", dependencies: {
			var res = [Target.Dependency]()
			res.append(.product(name: "ArgumentParser", package: "swift-argument-parser"))
			res.append(.product(name: "CLTLogger",      package: "clt-logger"))
			res.append(.product(name: "Logging",        package: "swift-log"))
			res.append(.product(name: "SystemPackage",  package: "swift-system"))
			
			/* Not _actual_ dependencies, but it is easier to have these recompiled when modified and current scheme is xct.
			 * This is the theory, but it does not work (Xcode 12.5).
			 * One can add the targets in the xct scheme manually though. */
//			res.append(.target(name: "xct-build"))
//			res.append(.target(name: "xct-gen"))
//			res.append(.target(name: "xct-versions"))
			return res
		}(), swiftSettings: swiftSettings))
#if canImport(CoreData)
		res.append(.executableTarget(name: "xct-build", dependencies: {
			var res = [Target.Dependency]()
			res.append(.product(name: "ArgumentParser",    package: "swift-argument-parser"))
			res.append(.product(name: "CLTLogger",         package: "clt-logger"))
			res.append(.product(name: "Logging",           package: "swift-log"))
			res.append(.product(name: "ProcessInvocation", package: "swift-process-invocation"))
			res.append(.product(name: "SafeGlobal",        package: "SafeGlobal"))
			res.append(.product(name: "StreamReader",      package: "stream-reader"))
			res.append(.product(name: "SystemPackage",     package: "swift-system"))
			res.append(.target(name: "XcodeJsonOutput"))
			res.append(.target(name: "XcodeTools"))
			return res
		}(), swiftSettings: swiftSettings))
		res.append(.executableTarget(name: "xct-gen", dependencies: {
			var res = [Target.Dependency]()
			res.append(.product(name: "ArgumentParser", package: "swift-argument-parser"))
			res.append(.product(name: "CLTLogger",      package: "clt-logger"))
			res.append(.product(name: "Logging",        package: "swift-log"))
			res.append(.product(name: "XibLoc",         package: "XibLoc"))
			res.append(.target(name: "XcodeProj"))
			res.append(.target(name: "XcodeTools"))
			return res
		}(), swiftSettings: swiftSettings))
		res.append(.executableTarget(name: "xct-pbxproj", dependencies: {
			var res = [Target.Dependency]()
			res.append(.product(name: "ArgumentParser", package: "swift-argument-parser"))
			res.append(.product(name: "CLTLogger",      package: "clt-logger"))
			res.append(.product(name: "Logging",        package: "swift-log"))
			res.append(.target(name: "XcodeProj"))
			return res
		}(), swiftSettings: swiftSettings))
		res.append(.executableTarget(name: "xct-versions", dependencies: {
			var res = [Target.Dependency]()
			res.append(.product(name: "ArgumentParser", package: "swift-argument-parser"))
			res.append(.target(name: "XcodeProj"))
			res.append(.target(name: "XcodeTools"))
			return res
		}(), swiftSettings: swiftSettings))
#endif
#if canImport(CoreData)
		res.append(.executableTarget(name: "hagvtool", dependencies: {
			var res = [Target.Dependency]()
			res.append(.product(name: "ArgumentParser", package: "swift-argument-parser"))
			res.append(.product(name: "CLTLogger",      package: "clt-logger"))
			res.append(.product(name: "Logging",        package: "swift-log"))
			res.append(.product(name: "SystemPackage",  package: "swift-system"))
			res.append(.target(name: "XcodeTools"))
			return res
		}(), swiftSettings: swiftSettings))
#endif
		
#if canImport(CoreData)
		/* ****************** */
		/* *** XcodeTools *** */
		/* ****************** */
		res.append(.target(name: "XcodeTools", dependencies: {
			var res = [Target.Dependency]()
			res.append(.product(name: "CollectionConcurrencyKit", package: "CollectionConcurrencyKit"))
			res.append(.product(name: "Logging",                  package: "swift-log"))
			res.append(.product(name: "SignalHandling",           package: "swift-signal-handling"))
			res.append(.product(name: "StreamReader",             package: "stream-reader"))
			res.append(.product(name: "SystemPackage",            package: "swift-system"))
			res.append(.target(name: "SPMProj"))
			res.append(.target(name: "Utils"))
			res.append(.target(name: "XcodeProj"))
			return res
		}(), swiftSettings: swiftSettings))
		res.append(.testTarget(name: "XcodeToolsTests", dependencies: {
			var res = [Target.Dependency]()
			res.append(.target(name: "XcodeTools")) /* <- Tested package */
			res.append(.product(name: "CLTLogger",        package: "clt-logger"))
			res.append(.product(name: "GlobalConfModule", package: "GlobalConfModule"))
			res.append(.product(name: "Logging",          package: "swift-log"))
			res.append(.product(name: "StreamReader",     package: "stream-reader"))
			res.append(.product(name: "SystemPackage",    package: "swift-system"))
			res.append(.target(name: "CommonForTests"))
			res.append(.target(name: "Utils"))
//			res.append(.target(name: "xct")) /* Because we use the xct binary in some tests. */
			return res
		}(), swiftSettings: swiftSettings))
#endif
		
		/* ********************* */
		/* *** SourceBuilder *** */
		/* ********************* */
#if canImport(CoreData)
		res.append(.target(name: "SourceBuilder", dependencies: {
			var res = [Target.Dependency]()
			res.append(.product(name: "Crypto",            package: "swift-crypto"))
			res.append(.product(name: "GlobalConfModule",  package: "GlobalConfModule"))
			res.append(.product(name: "Logging",           package: "swift-log"))
			res.append(.product(name: "ProcessInvocation", package: "swift-process-invocation"))
			res.append(.product(name: "SignalHandling",    package: "swift-signal-handling"))
			res.append(.product(name: "StreamReader",      package: "stream-reader"))
			res.append(.product(name: "XibLoc",            package: "XibLoc"))
			res.append(.target(name: "Utils"))
			res.append(.target(name: "XcodeTools"))
			res.append(.product(name: "SystemPackage",     package: "swift-system"))
			return res
		}(), swiftSettings: swiftSettings))
		/* *** */
		res.append(.testTarget(name: "SourceBuilderTests", dependencies: {
			var res = [Target.Dependency]()
			res.append(.target(name: "SourceBuilder")) /* <- Tested package */
			res.append(.product(name: "CLTLogger",     package: "clt-logger"))
			res.append(.product(name: "Logging",       package: "swift-log"))
			res.append(.product(name: "SystemPackage", package: "swift-system"))
			res.append(.target(name: "CommonForTests"))
			res.append(.target(name: "Utils"))
			return res
		}(), swiftSettings: swiftSettings))
#endif
		
		/* *************** */
		/* *** SPMProj *** */
		/* *************** */
		res.append(.target(name: "SPMProj", dependencies: {
			var res = [Target.Dependency]()
			res.append(.product(name: "Logging",          package: "swift-log"))
			res.append(.product(name: "GlobalConfModule", package: "GlobalConfModule"))
			res.append(.product(name: "SwiftPMDataModel", package: "swift-package-manager"))
			res.append(.target(name: "Utils"))
			return res
		}(), swiftSettings: swiftSettings))
		/* *** */
		res.append(.testTarget(name: "SPMProjTests", dependencies: [.target(name: "SPMProj"), .target(name: "CommonForTests")], swiftSettings: swiftSettings))
		
#if canImport(CoreData)
		/* ***************** */
		/* *** XcodeProj *** */
		/* ***************** */
		res.append(.target(name: "XcodeProj", dependencies: {
			var res = [Target.Dependency]()
			res.append(.product(name: "GlobalConfModule", package: "GlobalConfModule"))
			res.append(.product(name: "Logging",          package: "swift-log"))
			res.append(.product(name: "SafeGlobal",       package: "SafeGlobal"))
			res.append(.product(name: "UnwrapOrThrow",    package: "UnwrapOrThrow"))
			res.append(.target(name: "SPMProj"))
			res.append(.target(name: "Utils"))
			return res
		}(), resources: [
			.process("PBXModel.xcdatamodeld") // Dot not delete this token (for compilation sans sandbox): __COREDATA_TOKEN_XcodeProj_PBXModel
		], swiftSettings: swiftSettings))
		/* *** */
		res.append(.testTarget(name: "XcodeProjTests", dependencies: [.target(name: "XcodeProj"), .product(name: "ProcessInvocation", package: "swift-process-invocation"), .target(name: "CommonForTests")], swiftSettings: swiftSettings))
#endif
		
		/* *********************** */
		/* *** XcodeJsonOutput *** */
		/* *********************** */
		res.append(.target(name: "XcodeJsonOutput", dependencies: {
			var res = [Target.Dependency]()
			res.append(.product(name: "CLTLogger",        package: "clt-logger")) /* For the SGRs */
			res.append(.product(name: "GlobalConfModule", package: "GlobalConfModule"))
			res.append(.product(name: "Logging",          package: "swift-log"))
			res.append(.target(name: "Utils"))
			return res
		}(), swiftSettings: swiftSettings))
		
		/* ********************* */
		/* *** Other Helpers *** */
		/* ********************* */
		res.append(.target(name: "Utils", dependencies: {
			var res = [Target.Dependency]()
			res.append(.product(name: "SystemPackage",  package: "swift-system"))
			return res
		}(), swiftSettings: swiftSettings))
		/* A common init system for all tests. */
		res.append(.target(name: "CommonForTests", dependencies: {
			var res = [Target.Dependency]()
			res.append(.product(name: "Logging",   package: "swift-log"))
			res.append(.product(name: "CLTLogger", package: "clt-logger"))
			res.append(.product(name: "SystemPackage",  package: "swift-system"))
			res.append(.target(name: "Utils"))
			return res
		}(), path: "Tests/ Common", swiftSettings: swiftSettings))
		
		return res
	}()
)
