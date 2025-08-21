/* From officectl. */

import Foundation
import SystemPackage
import XCTest

import CLTLogger
import Logging

import Utils



public struct TestGlobals {
	
	public static nonisolated(unsafe) var hasBootstrapped = false
	public static func bootstrapIfNeeded() {
		guard !hasBootstrapped else {return}
		defer {hasBootstrapped = true}
		
		LoggingSystem.bootstrap({ id, metadataProvider in
			/* Note: CLTLoggers do not have IDs, so we do not use the id parameter of the handler. */
			var ret = CLTLogger(metadataProvider: metadataProvider)
			ret.logLevel = .trace
			return ret
		}, metadataProvider: nil)
	}
	
	public static let logger: Logger = {
		var logger = Logger(label: "com.xcode-actions.xcode-tools.tests")
		logger.logLevel = .trace
		return logger
	}()
	
	public static let testsDataPath: FilePath = {
		return FilePath(#filePath)
			.removingLastComponent().removingLastComponent().removingLastComponent()
			.appending("TestsData")
	}()
	public static let testsDataURL: URL = {
		testsDataPath.url
	}()
	
	public static let scriptsPath: FilePath = {
		return testsDataPath.appending("scripts")
	}()
	
	public static let filesPath: FilePath = {
		return testsDataPath.appending("files")
	}()
	
}


public extension XCTestCase {
	
	static nonisolated(unsafe) var hasBootstrapped: Bool {
		get {TestGlobals.hasBootstrapped}
		set {TestGlobals.hasBootstrapped = newValue}
	}
	static func bootstrapIfNeeded() {
		TestGlobals.bootstrapIfNeeded()
	}
	
	static var logger: Logger {
		TestGlobals.logger
	}
	
	static var testsDataPath: FilePath {
		TestGlobals.testsDataPath
	}
	static var testsDataURL: URL {
		TestGlobals.testsDataURL
	}
	
	static var scriptsPath: FilePath {
		TestGlobals.scriptsPath
	}
	
	static var filesPath: FilePath {
		TestGlobals.filesPath
	}
	
}
