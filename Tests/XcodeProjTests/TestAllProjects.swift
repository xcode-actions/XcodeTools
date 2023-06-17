import Foundation
import XCTest

import CommonForTests

@testable import XcodeProj



final class TestAllProjects : XCTestCase {
	
	override class func setUp() {
		super.setUp()
		bootstrapIfNeeded()
	}
	
	static let testProjectsURL = testsDataURL.appendingPathComponent("projects")
	
	func testReserialization() throws {
		struct CannotGetDirEnumerator : Error {var url: URL}
		
		let fm = FileManager.default
		guard let de = fm.enumerator(atPath: Self.testProjectsURL.path) else {
			throw CannotGetDirEnumerator(url: Self.testProjectsURL)
		}
		
		while let f = de.nextObject() as! String? {
			guard f.hasSuffix(".xcodeproj") ||  f.hasSuffix(".xcodeproj/") else {
				continue
			}
			
			let xcodeprojURL = URL(fileURLWithPath: f, isDirectory: true, relativeTo: Self.testProjectsURL)
			print("Testing project at path \(xcodeprojURL.path)")
			
			let xcodeproj = try XcodeProj(xcodeprojURL: xcodeprojURL)
			let originalContents = try Data(contentsOf: xcodeproj.pbxprojURL)
			try XCTAssertEqual(originalContents, Data(xcodeproj.pbxproj.stringSerialization(projectName: xcodeproj.projectName).utf8))
			
			/* Uncomment the line below to write the reserialized files to disk to find diffs using git. */
//			try Data(xcodeproj.pbxproj.stringSerialization(projectName: xcodeproj.projectName).utf8).write(to: xcodeproj.pbxprojURL)
		}
	}
	
}
