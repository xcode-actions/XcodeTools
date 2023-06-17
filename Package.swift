// swift-tools-version:5.5
import PackageDescription

import Foundation


let swiftSettings: [SwiftSetting] = []
//let swiftSettings: [SwiftSetting] = [.unsafeFlags(["-Xfrontend", "-warn-concurrency", "-Xfrontend", "-enable-actor-data-race-checks"])]


/* Detect if we need the eXtenderZ.
 * If we do (on Apple platforms where the non-public Foundation implementation is used), the eXtenderZ should be able to be imported.
 * See Process+Utils for reason why we use the eXtenderZ. */
let needseXtenderZ = (NSStringFromClass(Process().classForCoder) != "NSTask")
/* Do we need the _GNU_SOURCE exports? This allows using execvpe on Linux. */
#if !os(Linux)
let needsGNUSourceExports = false
#else
let needsGNUSourceExports = true
#endif


let package = Package(
	name: "XcodeTools",
	platforms: [.macOS(.v12)],
	products: {
		var res = [Product]()
		
		/* ******************* */
		/* *** Executables *** */
		/* ******************* */
		
		/* A launcher for xcode tools binaries (xct-*). */
		res.append(.executable(name: "xct", targets: ["xct"]))
		res.append(.executable(name: "xct-build", targets: ["xct-build"]))
		res.append(.executable(name: "xct-gen", targets: ["xct-gen"]))
		res.append(.executable(name: "xct-pbxproj", targets: ["xct-pbxproj"]))
		res.append(.executable(name: "xct-versions", targets: ["xct-versions"]))
		/* Obsolete; kept for backwards-compatibility. Will be removed. */
		res.append(.executable(name: "hagvtool", targets: ["hagvtool"]))
		
		/* ****************** */
		/* *** Frameworks *** */
		/* ****************** */
		
		res.append(.library(name: "XcodeTools", targets: ["XcodeTools"]))
		res.append(.library(name: "SourceBuilder", targets: ["SourceBuilder"]))
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
		res.append(.package(url: "https://github.com/apple/swift-argument-parser.git",         from: "1.2.2"))
//		res.append(.package(url: "https://github.com/apple/swift-crypto.git",                  from: "2.4.0"))
		res.append(.package(url: "https://github.com/apple/swift-log.git",                     from: "1.5.2"))
		res.append(.package(url: "https://github.com/happn-app/XibLoc.git",                    from: "1.2.5"))
		res.append(.package(url: "https://github.com/SDGGiesbrecht/swift-crypto.git",          from: "0.20400.0")) /* Because we’re using SDGGiesbrecht’s fork of swift-package-manager, we also have to use his fork of swift-crypto. */
		res.append(.package(url: "https://github.com/SDGGiesbrecht/swift-package-manager.git", from: "0.50800.0")) /* Apple does not semver SPM for whatever reason. */
		res.append(.package(url: "https://github.com/xcode-actions/clt-logger.git",            from: "0.5.1"))
		res.append(.package(url: "https://github.com/xcode-actions/stream-reader.git",         from: "3.5.0"))
		res.append(.package(url: "https://github.com/xcode-actions/swift-signal-handling.git", from: "1.1.0"))
#if !canImport(System)
		res.append(.package(url: "https://github.com/apple/swift-system.git",                  from: "1.0.0"))
#endif
		if needseXtenderZ {
			res.append(.package(url: "https://github.com/xcode-actions/eXtenderZ.git",          from: "1.0.7"))
		}
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
#if !canImport(System)
			res.append(.product(name: "SystemPackage",  package: "swift-system"))
#endif
			res.append(.target(name: "CMacroExports"))
			res.append(.target(name: "XcodeTools"))
			
			/* Not _actual_ dependencies, but it is easier to have these recompiled when modified and current scheme is xct.
			 * This is the theory, but it does not work (Xcode 12.5).
			 * One can add the targets in the xct scheme manually though. */
//			res.append(.target(name: "xct-build"))
//			res.append(.target(name: "xct-gen"))
//			res.append(.target(name: "xct-versions"))
			return res
		}(), swiftSettings: swiftSettings))
		res.append(.executableTarget(name: "xct-build", dependencies: {
			var res = [Target.Dependency]()
			res.append(.product(name: "ArgumentParser", package: "swift-argument-parser"))
			res.append(.product(name: "CLTLogger",      package: "clt-logger"))
			res.append(.product(name: "Logging",        package: "swift-log"))
			res.append(.product(name: "StreamReader",   package: "stream-reader"))
#if !canImport(System)
			res.append(.product(name: "SystemPackage",  package: "swift-system"))
#endif
			res.append(.target(name: "XcodeJsonOutput"))
			res.append(.target(name: "XcodeTools"))
			return res
		}(), swiftSettings: swiftSettings))
#if canImport(CoreData)
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
		res.append(.executableTarget(name: "hagvtool", dependencies: {
			var res = [Target.Dependency]()
			res.append(.product(name: "ArgumentParser", package: "swift-argument-parser"))
			res.append(.product(name: "CLTLogger",      package: "clt-logger"))
			res.append(.product(name: "Logging",        package: "swift-log"))
#if !canImport(System)
			res.append(.product(name: "SystemPackage",  package: "swift-system"))
#endif
			res.append(.target(name: "XcodeTools"))
			return res
		}(), swiftSettings: swiftSettings))
		
		/* ****************** */
		/* *** XcodeTools *** */
		/* ****************** */
		res.append(.target(name: "XcodeTools", dependencies: {
			var res = [Target.Dependency]()
			res.append(.product(name: "Logging",        package: "swift-log"))
			res.append(.product(name: "SignalHandling", package: "swift-signal-handling"))
			res.append(.product(name: "StreamReader",   package: "stream-reader"))
#if !canImport(System)
			res.append(.product(name: "SystemPackage",  package: "swift-system"))
#endif
			res.append(.target(name: "CMacroExports"))
			res.append(.target(name: "SPMProj"))
			res.append(.target(name: "Utils"))
			res.append(.target(name: "XcodeProj"))
			if needseXtenderZ {
				res.append(.product(name: "eXtenderZ-static", package: "eXtenderZ"))
				res.append(.target(name: "CNSTaskHelptender"))
			}
			if needsGNUSourceExports {
				res.append(.target(name: "CGNUSourceExports"))
			}
			/* XcodeTools depends (indirectly) on xct to launch processes with additional file descriptors.
			 * To avoid a cyclic dependency, we do not add it in the deps. */
//			res.append(.target(name: "xct"))
			return res
		}(), swiftSettings: swiftSettings))
		res.append(.testTarget(name: "XcodeToolsTests", dependencies: {
			var res = [Target.Dependency]()
			res.append(.target(name: "XcodeTools")) /* <- Tested package */
			res.append(.product(name: "CLTLogger",     package: "clt-logger"))
			res.append(.product(name: "Logging",       package: "swift-log"))
			res.append(.product(name: "StreamReader",  package: "stream-reader"))
#if !canImport(System)
			res.append(.product(name: "SystemPackage",  package: "swift-system"))
#endif
			res.append(.target(name: "Utils"))
//			res.append(.target(name: "xct")) /* Because we use the xct binary in some tests. */
			return res
		}(), swiftSettings: swiftSettings))
		
		/* ********************* */
		/* *** SourceBuilder *** */
		/* ********************* */
		res.append(.target(name: "SourceBuilder", dependencies: {
			var res = [Target.Dependency]()
			res.append(.product(name: "Crypto",         package: "swift-crypto"))
			res.append(.product(name: "Logging",        package: "swift-log"))
			res.append(.product(name: "SignalHandling", package: "swift-signal-handling"))
			res.append(.product(name: "StreamReader",   package: "stream-reader"))
			res.append(.product(name: "XibLoc",         package: "XibLoc"))
			res.append(.target(name: "Utils"))
			res.append(.target(name: "XcodeTools"))
#if !canImport(System)
			res.append(.product(name: "SystemPackage",  package: "swift-system"))
#endif
			return res
		}(), swiftSettings: swiftSettings))
		/* *** */
		res.append(.testTarget(name: "SourceBuilderTests", dependencies: {
			var res = [Target.Dependency]()
			res.append(.target(name: "SourceBuilder")) /* <- Tested package */
			res.append(.product(name: "CLTLogger",     package: "clt-logger"))
			res.append(.product(name: "Logging",       package: "swift-log"))
#if !canImport(System)
			res.append(.product(name: "SystemPackage", package: "swift-system"))
#endif
			res.append(.target(name: "Utils"))
			return res
		}(), swiftSettings: swiftSettings))
		
		/* *************** */
		/* *** SPMProj *** */
		/* *************** */
		res.append(.target(name: "SPMProj", dependencies: {
			var res = [Target.Dependency]()
			res.append(.product(name: "Logging", package: "swift-log"))
			res.append(.product(name: "SwiftPMDataModel", package: "swift-package-manager"))
			res.append(.target(name: "Utils"))
			return res
		}(), swiftSettings: swiftSettings))
		/* *** */
		res.append(.testTarget(name: "SPMProjTests", dependencies: [.target(name: "SPMProj")], swiftSettings: swiftSettings))
		
#if canImport(CoreData)
		/* ***************** */
		/* *** XcodeProj *** */
		/* ***************** */
		res.append(.target(name: "XcodeProj", dependencies: {
			var res = [Target.Dependency]()
			res.append(.product(name: "Logging", package: "swift-log"))
			res.append(.target(name: "SPMProj"))
			res.append(.target(name: "Utils"))
			return res
		}(), resources: [
			.process("PBXModel.xcdatamodeld") // Dot not delete this token (for compilation sans sandbox): __COREDATA_TOKEN_XcodeProj_PBXModel
		], swiftSettings: swiftSettings))
		/* *** */
		res.append(.testTarget(name: "XcodeProjTests", dependencies: [.target(name: "XcodeProj")], swiftSettings: swiftSettings))
#endif
		
		/* *********************** */
		/* *** XcodeJsonOutput *** */
		/* *********************** */
		res.append(.target(name: "XcodeJsonOutput", dependencies: {
			var res = [Target.Dependency]()
			res.append(.product(name: "CLTLogger", package: "clt-logger")) /* For the SGRs */
			res.append(.product(name: "Logging",   package: "swift-log"))
			res.append(.target(name: "Utils"))
			return res
		}(), swiftSettings: swiftSettings))
		
		/* ********************* */
		/* *** Other Helpers *** */
		/* ********************* */
		/* Some complex macros exported as functions to be used in Swift. */
		res.append(.target(name: "CMacroExports", swiftSettings: swiftSettings))
		res.append(.target(name: "Utils", dependencies: {
			var res = [Target.Dependency]()
#if !canImport(System)
			res.append(.product(name: "SystemPackage",  package: "swift-system"))
#endif
			return res
		}(), swiftSettings: swiftSettings))
		if needseXtenderZ {
			res.append(.target(name: "CNSTaskHelptender", dependencies: [.product(name: "eXtenderZ-static", package: "eXtenderZ")], swiftSettings: swiftSettings))
		}
		if needsGNUSourceExports {
			res.append(.target(name: "CGNUSourceExports", swiftSettings: swiftSettings))
		}
		
		return res
	}()
)
