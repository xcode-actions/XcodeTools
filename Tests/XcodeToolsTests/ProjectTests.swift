import Foundation
import Testing

import CLTLogger
import Logging
import GlobalConfModule

import CommonForTests

@testable import XcodeTools



struct ProjectTests {
	
	init() {
		TestGlobals.bootstrapIfNeeded()
		Conf.setRootValue(TestGlobals.logger, for: \.xcodeTools.logger)
	}
	
	static let project1URL = TestGlobals.testsDataURL.appendingPathComponent("project1").appendingPathComponent("Project 1.xcodeproj")
	static let project2URL = TestGlobals.testsDataURL.appendingPathComponent("project2").appendingPathComponent("project2.xcodeproj")
	
	@Test
	func testProject1() async throws {
		let project = try Project(xcodeprojURL: Self.project1URL)
		let targets = try await project.getTargets()
		#expect(targets.count == 2)
		let target1 = try #require(targets.filter{ try $0.getName() == "Target 1" }.onlyElement)
		let target2 = try #require(targets.filter{ try $0.getName() == #"Target "2""# }.onlyElement)
		#expect(try await target1.getExplicitDirectDependencies() == [target2])
		#expect(try await target2.getExplicitDirectDependencies() == [])
	}
	
	@Test
	func testProject2() async throws {
		let project = try Project(xcodeprojURL: Self.project2URL)
		let targets = try await project.getTargets()
		#expect(targets.count == 5)
		let xcodeTarget = try #require(targets.filter{ try $0.getName() == "project2" }.onlyElement)
		let amazingLibTarget = try #require(targets.filter{ try $0.getName() == "GAmazingLib" }.onlyElement)
		let amazingLib2Target = try #require(targets.filter{ try $0.getName() == "GAmazingLib2" }.onlyElement)
		let amazingLib3Target = try #require(targets.filter{ try $0.getName() == "GAmazingLib3" }.onlyElement)
		#expect(try await xcodeTarget.getExplicitDirectDependencies() == [amazingLibTarget])
		#expect(try await xcodeTarget.getImplicitDirectDependencies() == [amazingLib2Target, amazingLib3Target])
		#expect(try await xcodeTarget.getRecursiveDependencies() == [amazingLibTarget, amazingLib2Target, amazingLib3Target])
		#expect(try await project.getDependents(of: amazingLibTarget) == [xcodeTarget])
	}
	
}
