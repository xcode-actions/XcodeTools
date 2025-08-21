/* From officectl. */

import Foundation
import SystemPackage
import XCTest

import CLTLogger
import Logging

import Utils



public extension XCTestCase {
	
	static nonisolated(unsafe) var hasBootstrapped = false
	static func bootstrapIfNeeded() {
		guard !hasBootstrapped else {return}
		defer {hasBootstrapped = true}
		
		LoggingSystem.bootstrap({ id, metadataProvider in
			/* Note: CLTLoggers do not have IDs, so we do not use the id parameter of the handler. */
			var ret = CLTLogger(metadataProvider: metadataProvider)
			ret.logLevel = .trace
			return ret
		}, metadataProvider: nil)
	}
	
	static let logger: Logger = {
		var logger = Logger(label: "com.xcode-actions.xcode-tools.tests")
		logger.logLevel = .trace
		return logger
	}()
	
	static let testsDataPath: FilePath = {
		return FilePath(#filePath)
			.removingLastComponent().removingLastComponent().removingLastComponent()
			.appending("TestsData")
	}()
	static let testsDataURL: URL = {
		testsDataPath.url
	}()
	
	static let scriptsPath: FilePath = {
		return testsDataPath.appending("scripts")
	}()
	
	static let filesPath: FilePath = {
		return testsDataPath.appending("files")
	}()
	
}
