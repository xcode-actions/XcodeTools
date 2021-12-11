// swift-tools-version:5.5
import PackageDescription

import Foundation


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


var dependencies: [Package.Dependency] = [
	.package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.0.0"),
	.package(url: "https://github.com/apple/swift-crypto.git", from: "1.1.6"),
	.package(url: "https://github.com/apple/swift-log.git", from: "1.4.2"),
	.package(url: "https://github.com/apple/swift-system.git", from: "1.0.0"),
	.package(url: "https://github.com/happn-tech/XibLoc.git", from: "1.1.1"),
	.package(url: "https://github.com/xcode-actions/clt-logger.git", from: "0.3.6"),
	.package(url: "https://github.com/xcode-actions/stream-reader.git", from: "3.2.3"),
	.package(url: "https://github.com/xcode-actions/swift-signal-handling.git", from: "1.0.0")
]


var targets = [Target]()
var products = [Product]()



/* ********************* */
/* *** SourceBuilder *** */
/* ********************* */

products.append(.library(name: "SourceBuilder", targets: ["SourceBuilder"]))
targets.append(contentsOf: [
	.target(name: "SourceBuilder", dependencies: [
		.product(name: "Crypto",         package: "swift-crypto"), /* If we supported macOS only we’d use CryptoKit instead of this… */
		.product(name: "Logging",        package: "swift-log"),
		.product(name: "SignalHandling", package: "swift-signal-handling"),
		.product(name: "StreamReader",   package: "stream-reader"),
		.product(name: "SystemPackage",  package: "swift-system"),
		.product(name: "XibLoc",         package: "XibLoc"),
		.target(name: "Utils"),
		.target(name: "XcodeTools")
	]),
	.testTarget(name: "SourceBuilderTests", dependencies: [
		.target(name: "SourceBuilder"),
		
		.product(name: "CLTLogger",     package: "clt-logger"),
		.product(name: "Logging",       package: "swift-log"),
		.product(name: "SystemPackage", package: "swift-system"),
		.target(name: "Utils")
	])
])


/* ***************** */
/* *** XcodeProj *** */
/* ***************** */

#if canImport(CoreData)
/* A lib one can use to manipulate Xcode Projects. */
products.append(.library(name: "XcodeProj", targets: ["XcodeProj"]))
targets.append(contentsOf: [
	.target(name: "XcodeProj", dependencies: [
		.product(name: "Logging", package: "swift-log"),
		.target(name: "Utils")
	], resources: [
			.copy("CoreDataModelArtifacts_PBXModel/PBXModel.momd")
	]),
	.testTarget(name: "XcodeProjTests", dependencies: [.target(name: "XcodeProj")])
])
#endif


/* *********************** */
/* *** XcodeJsonOutput *** */
/* *********************** */

targets.append(contentsOf: [
	.target(name: "XcodeJsonOutput", dependencies: [
		.product(name: "CLTLogger", package: "clt-logger"), /* For the SGRs */
		.product(name: "Logging",   package: "swift-log"),
		.target(name: "Utils")
	])
])


/* *************** */
/* *** SPMProj *** */
/* *************** */

/* A lib one can use to manipulate SPM Projects. */
products.append(.library(name: "SPMProj", targets: ["SPMProj"]))
targets.append(contentsOf: [
	.target(name: "SPMProj", dependencies: [
		.product(name: "Logging", package: "swift-log"),
		.target(name: "Utils")
	]),
	.testTarget(name: "SPMProjTests", dependencies: [.target(name: "SPMProj")])
])


/* ****************** */
/* *** XcodeTools *** */
/* ****************** */

products.append(.library(name: "XcodeTools", targets: ["XcodeTools"]))

let eXtenderZDeps: [Target.Dependency] = [
	.product(name: "eXtenderZ-static", package: "eXtenderZ"),
	.target(name: "CNSTaskHelptender")
]
let gnuSourceExportsDeps: [Target.Dependency] = [
	.target(name: "CGNUSourceExports")
]
targets.append(contentsOf: [
	.target(name: "XcodeTools", dependencies: [
		.product(name: "Logging",        package: "swift-log"),
		.product(name: "SignalHandling", package: "swift-signal-handling"),
		.product(name: "StreamReader",   package: "stream-reader"),
		.product(name: "SystemPackage",  package: "swift-system"),
		.target(name: "CMacroExports"),
		.target(name: "Utils"),
		/* XcodeTools depends (indirectly) on xct to launch processes with additional file descriptors.
		 * To avoid a cyclic dependency, we do not add it in the deps. */
//		.target(name: "xct"),
	] + (needseXtenderZ ? eXtenderZDeps : []) + (needsGNUSourceExports ? gnuSourceExportsDeps : [])),
	.testTarget(name: "XcodeToolsTests", dependencies: [
		.target(name: "XcodeTools"),
		
		.product(name: "CLTLogger",     package: "clt-logger"),
		.product(name: "Logging",       package: "swift-log"),
		.product(name: "StreamReader",  package: "stream-reader"),
		.product(name: "SystemPackage", package: "swift-system"),
		.target(name: "Utils"),
		
		/* This dep is technically related to XcodeTools. See XcodeTools deps. */
		.target(name: "xct")
	]),
])


/* *********** */
/* *** xct *** */
/* *********** */

products.append(.executable(name: "xct",          targets: ["xct"]))
targets.append(
	/* A launcher for xcode tools binaries (xct-*) */
	.executableTarget(name: "xct", dependencies: [
		.product(name: "ArgumentParser", package: "swift-argument-parser"),
		.product(name: "CLTLogger",      package: "clt-logger"),
		.product(name: "Logging",        package: "swift-log"),
		.product(name: "SystemPackage",  package: "swift-system"),
		.target(name: "CMacroExports"),
		.target(name: "XcodeTools"),
		
		/* Not _actual_ dependencies, but it is easier to have these recompiled when modified and current scheme is xct.
		 * This is the theory, but it does not work (Xcode 12.5).
		 * One can add the targets in the xct scheme manually though. */
		.target(name: "xct-build"),
		/* The targets below are commented for Linux. */
//		.target(name: "xct-gen"),
//		.target(name: "xct-versions")
	])
)
products.append(.executable(name: "xct-build",    targets: ["xct-build"]))
targets.append(
	.executableTarget(name: "xct-build", dependencies: [
		.product(name: "ArgumentParser", package: "swift-argument-parser"),
		.product(name: "CLTLogger",      package: "clt-logger"),
		.product(name: "Logging",        package: "swift-log"),
		.product(name: "StreamReader",   package: "stream-reader"),
		.product(name: "SystemPackage",  package: "swift-system"),
		.target(name: "XcodeJsonOutput"),
		.target(name: "XcodeTools")
	])
)
#if canImport(CoreData)
products.append(.executable(name: "xct-gen", targets: ["xct-gen"]))
targets.append(
	.executableTarget(name: "xct-gen", dependencies: [
		.product(name: "ArgumentParser", package: "swift-argument-parser"),
		.target(name: "XcodeProj"),
		.target(name: "XcodeTools")
	])
)
products.append(.executable(name: "xct-versions", targets: ["xct-versions"]))
targets.append(
	.executableTarget(name: "xct-versions", dependencies: [
		.product(name: "ArgumentParser", package: "swift-argument-parser"),
		.target(name: "XcodeProj"),
		.target(name: "XcodeTools")
	])
)
#endif
/* Obsolete; kept for backwards-compatibility. Will be removed. */
products.append(.executable(name: "hagvtool", targets: ["hagvtool"]))
targets.append(
	.executableTarget(name: "hagvtool", dependencies: [
		.product(name: "ArgumentParser", package: "swift-argument-parser"),
		.product(name: "CLTLogger",      package: "clt-logger"),
		.product(name: "Logging",        package: "swift-log"),
		.product(name: "SystemPackage",  package: "swift-system"),
		.target(name: "XcodeTools")
	])
)


/* **************** */
/* *** XCTUtils *** */
/* **************** */

/* Some re-usable utilities. */
products.append(.library(name: "XCTUtils", targets: ["Utils"]))
targets.append(contentsOf: [
	.target(name: "Utils", dependencies: [
		.product(name: "SystemPackage", package: "swift-system")
	])
])


/* ********************* */
/* *** CMacroExports *** */
/* ********************* */

/* Some complex macros exported as functions to be used in Swift. */
targets.append(.target(name: "CMacroExports"))


/* ************************* */
/* *** CGNUSourceExports *** */
/* ************************* */

if needsGNUSourceExports {
	targets.append(.target(name: "CGNUSourceExports"))
}


/* ***************** */
/* *** eXtenderZ *** */
/* ***************** */

if needseXtenderZ {
	targets.append(.target(name: "CNSTaskHelptender", dependencies: [.product(name: "eXtenderZ-static", package: "eXtenderZ")]))
	dependencies.append(.package(url: "https://github.com/xcode-actions/eXtenderZ.git", from: "1.0.7"))
}


let package = Package(
	name: "XcodeTools",
	platforms: [.macOS(.v12)],
	products: products,
	dependencies: dependencies,
	targets: targets
)
