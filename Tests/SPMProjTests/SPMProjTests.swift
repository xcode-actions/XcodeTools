import Foundation
import XCTest

import CommonForTests

@testable import SPMProj



final class SPMProjTests : XCTestCase {
	
	/* Why, oh why this is not throwing? idk. */
	override class func setUp() {
		super.setUp()
		bootstrapIfNeeded()
	}
	
	static let package1URL = testsDataURL.appendingPathComponent("package1")
	
	func testPackage1() throws {
		let proj = try SPMProj(url: Self.package1URL)
		
		XCTAssertEqual(Set(proj.targets.map(\.name)), Set(arrayLiteral: "package1", "package1Tests"))
		XCTAssertEqual(Set((proj.targets.first{ $0.name == "package1"      }?.sources) ?? []), Set(arrayLiteral: Self.package1URL.appendingPathComponent("Sources").appendingPathComponent("package1").appendingPathComponent("Package1.swift")))
		XCTAssertEqual(Set((proj.targets.first{ $0.name == "package1Tests" }?.sources) ?? []), Set(arrayLiteral: Self.package1URL.appendingPathComponent("Tests").appendingPathComponent("package1Tests").appendingPathComponent("Package1Tests.swift")))
	}
	
}
