import Foundation
import XCTest

import CLTLogger
import Logging
import GlobalConfModule

import CommonForTests

@testable import XcodeTools



final class ProjectTests : XCTestCase {
	
	override class func setUp() {
		super.setUp()
		bootstrapIfNeeded()
		Conf.setRootValue(logger, for: \.xcodeTools.logger)
	}
	
	static let project1URL = testsDataURL.appendingPathComponent("project1").appendingPathComponent("Project 1.xcodeproj")
	static let project2URL = testsDataURL.appendingPathComponent("project2").appendingPathComponent("project2.xcodeproj")
	
	func testProject1() throws {
		let project = try Project(xcodeprojURL: Self.project1URL)
		let targets = try project.getTargets()
		XCTAssertEqual(targets.count, 2)
		let target1 = try XCTUnwrap(targets.filter{ try $0.getName() == "Target 1" }.onlyElement)
		let target2 = try XCTUnwrap(targets.filter{ try $0.getName() == #"Target "2""# }.onlyElement)
		try XCTAssertEqual(target1.getExplicitDirectDependencies(), [target2])
		try XCTAssertEqual(target2.getExplicitDirectDependencies(), [])
	}
	
	func testProject2() throws {
		let project = try Project(xcodeprojURL: Self.project2URL)
		let targets = try project.getTargets()
		XCTAssertEqual(targets.count, 5)
		let xcodeTarget = try XCTUnwrap(targets.filter{ try $0.getName() == "project2" }.onlyElement)
		let amazingLibTarget = try XCTUnwrap(targets.filter{ try $0.getName() == "GAmazingLib" }.onlyElement)
		let amazingLib2Target = try XCTUnwrap(targets.filter{ try $0.getName() == "GAmazingLib2" }.onlyElement)
		let amazingLib3Target = try XCTUnwrap(targets.filter{ try $0.getName() == "GAmazingLib3" }.onlyElement)
		try XCTAssertEqual(xcodeTarget.getExplicitDirectDependencies(), [amazingLibTarget])
		try XCTAssertEqual(xcodeTarget.getImplicitDirectDependencies(), [amazingLib2Target, amazingLib3Target])
		try XCTAssertEqual(xcodeTarget.getRecursiveDependencies(), [amazingLibTarget, amazingLib2Target, amazingLib3Target])
		try XCTAssertEqual(project.getDependents(of: amazingLibTarget), [xcodeTarget])
	}
	
}
