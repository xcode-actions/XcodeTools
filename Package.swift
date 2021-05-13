// swift-tools-version:5.4
import PackageDescription


import Foundation

/* Detect if we need the eXtenderZ. If we do (on Apple platforms where the non-
 * public Foundation implementation is used), the eXtenderZ should be able to be
 * imported. See Process+Utils for reason why we use the eXtenderZ. */
let eXtenderZ: (packageDep: Package.Dependency, target: Target, targetDep1: Target.Dependency, targetDep2: Target.Dependency)? = (
	NSStringFromClass(Process().classForCoder) != "NSTask" ?
		(
			packageDep: .package(url: "https://github.com/xcode-actions/eXtenderZ.git", from: "1.0.7"),
			target:     .target(name: "CNSTaskHelptender", dependencies: [.product(name: "eXtenderZ-static", package: "eXtenderZ")]),
			targetDep1: .product(name: "eXtenderZ-static", package: "eXtenderZ"),
			targetDep2: .target(name: "CNSTaskHelptender")
		) :
		nil
)


let package = Package(
	name: "XcodeTools",
	platforms: [
		.macOS(.v10_15)
	],
	products: [
		/* A lib one can use to manipulate Xcode Projects. */
		.library(name: "XcodeProj", targets: ["XcodeProj"]),
		
		/* The xct and xct-* executable, and the lib they use. */
		.library(name: "libxct", targets: ["libxct"]),
		.executable(name: "xct", targets: ["xct"]),
		.executable(name: "xct-build", targets: ["xct-build"]),
		.executable(name: "xct-versions", targets: ["xct-versions"]),
		
		/* Some re-usable utilities. */
		.library(name: "XCTUtils", targets: ["Utils"]),
		
		/* Obsolete; kept for backwards-compatibility. Will be removed. */
		.executable(name: "hagvtool", targets: ["hagvtool"])
	],
	dependencies: [
		.package(url: "https://github.com/apple/swift-argument-parser.git", from: "0.4.0"),
		.package(url: "https://github.com/apple/swift-log.git", from: "1.4.2"),
		.package(url: "https://github.com/apple/swift-system.git", from: "0.0.1"),
		.package(url: "https://github.com/xcode-actions/clt-logger.git", from: "0.3.0"),
		.package(url: "https://github.com/xcode-actions/stream-reader.git", from: "3.2.1"),
		.package(url: "https://github.com/xcode-actions/swift-signal-handling.git", from: "0.2.0"),
		eXtenderZ?.packageDep
	].compactMap{ $0 },
	targets: [
		.target(name: "CMacroExports"),
		eXtenderZ?.target,
		
		.target(name: "Utils"),
		
		.target(name: "XcodeProj", dependencies: [
			.target(name: "Utils"),
			.product(name: "Logging", package: "swift-log")
		], resources: [
			.copy("CoreDataModelArtifacts_PBXModel/PBXModel.momd")
		]),
		.testTarget(name: "XcodeProjTests", dependencies: [.target(name: "XcodeProj")]),
		
		.target(name: "XcodeJsonOutput", dependencies: [
			.product(name: "Logging", package: "swift-log"),
			.target(name: "Utils")
		]),
		
		.target(name: "libxct", dependencies: [
			.product(name: "Logging",        package: "swift-log"),
			.product(name: "SignalHandling", package: "swift-signal-handling"),
			.product(name: "StreamReader",   package: "stream-reader"),
			.product(name: "SystemPackage",  package: "swift-system"),
			.target(name: "CMacroExports"),
			.target(name: "Utils"),
			.target(name: "XcodeProj"),
			/* libxct depends (indirectly) on xct to launch processes w/ additional
			 * fds. To avoid a cyclic dependency, we do not add it in the deps. */
//			.target(name: "xct"),
			
			eXtenderZ?.targetDep1, eXtenderZ?.targetDep2
		].compactMap{ $0 }),
		.testTarget(name: "libxctTests", dependencies: [
			.target(name: "libxct"),
			.product(name: "CLTLogger",     package: "clt-logger"),
			.product(name: "Logging",       package: "swift-log"),
			.product(name: "StreamReader",  package: "stream-reader"),
			.product(name: "SystemPackage", package: "swift-system"),
			
			/* This dep is technically related to libxct. See libxct deps. */
			.target(name: "xct")
		]),
		
		/* A launcher for xcode tools binaries (xct-*) */
		.executableTarget(name: "xct", dependencies: [
			.product(name: "ArgumentParser", package: "swift-argument-parser"),
			.product(name: "CLTLogger",      package: "clt-logger"),
			.product(name: "Logging",        package: "swift-log"),
			.product(name: "SystemPackage",  package: "swift-system"),
			.target(name: "CMacroExports"),
			.target(name: "libxct"),
			
			/* Not _actual_ dependencies, but it is easier to have these recompiled
			 * when modified and current scheme is xct. This is the theory, but it
			 * does not work (Xcode 12.5). One can add the targets in the xct
			 * scheme manually though. */
			.target(name: "xct-build"),
			.target(name: "xct-versions")
		]),
		
		.executableTarget(name: "xct-build", dependencies: [
			.product(name: "ArgumentParser", package: "swift-argument-parser"),
			.product(name: "CLTLogger",      package: "clt-logger"),
			.product(name: "Logging",        package: "swift-log"),
			.product(name: "StreamReader",   package: "stream-reader"),
			.product(name: "SystemPackage",  package: "swift-system"),
			.target(name: "libxct"),
			.target(name: "XcodeJsonOutput"),
			.target(name: "XcodeProj")
		]),
		
		.executableTarget(name: "xct-versions", dependencies: [
			.product(name: "ArgumentParser", package: "swift-argument-parser"),
			.target(name: "libxct"),
			.target(name: "XcodeProj")
		]),
		
		/* Obsolete; kept for backwards-compatibility. Will be removed. */
		.executableTarget(name: "hagvtool", dependencies: [
			.product(name: "ArgumentParser", package: "swift-argument-parser"),
			.product(name: "CLTLogger",      package: "clt-logger"),
			.product(name: "Logging",        package: "swift-log"),
			.product(name: "SystemPackage",  package: "swift-system"),
			.target(name: "libxct")
		])
	].compactMap{ $0 }
)
