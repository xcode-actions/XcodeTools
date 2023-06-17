import Foundation
import XCTest

import CLTLogger
import Logging

import CommonForTests

@testable import XcodeTools



final class ProjectTests : XCTestCase {
	
	override class func setUp() {
		super.setUp()
		bootstrapIfNeeded()
		XcodeToolsConfig.logger = logger
	}
	
	static let project2URL = testsDataURL.appendingPathComponent("project2").appendingPathComponent("project2.xcodeproj")
	
	func testProject2() throws {
		let project = try Project(xcodeprojURL: Self.project2URL)
		try XCTAssertEqual(project.getTargets().count, 4)
	}
	
}
