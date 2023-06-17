import Foundation
import XCTest

import CommonForTests

@testable import XcodeProj



final class XCConfigTests : XCTestCase {
	
	override class func setUp() {
		super.setUp()
		bootstrapIfNeeded()
	}
	
	func testIncludeStuff() throws {
		XCTAssertThrowsError(try XCConfig.Line(lineString: #"#include ? "hello""#))
		
		do {
			let includeString = #"# include?"hello""#
			XCTAssertNoThrow(try XCConfig.Line(lineString: includeString, allowSpacesAfterSharp: true, allowNoSpacesAfterInclude: true))
			XCTAssertThrowsError(try XCConfig.Line(lineString: includeString, allowSpacesAfterSharp: true, allowNoSpacesAfterInclude: false))
			XCTAssertThrowsError(try XCConfig.Line(lineString: includeString, allowSpacesAfterSharp: false, allowNoSpacesAfterInclude: true))
			XCTAssertThrowsError(try XCConfig.Line(lineString: includeString, allowSpacesAfterSharp: false, allowNoSpacesAfterInclude: false))
		}
		
		do {
			let includeString = #"# include? "hello""#
			XCTAssertNoThrow(try XCConfig.Line(lineString: includeString, allowSpacesAfterSharp: true, allowNoSpacesAfterInclude: true))
			XCTAssertNoThrow(try XCConfig.Line(lineString: includeString, allowSpacesAfterSharp: true, allowNoSpacesAfterInclude: false))
			XCTAssertThrowsError(try XCConfig.Line(lineString: includeString, allowSpacesAfterSharp: false, allowNoSpacesAfterInclude: true))
			XCTAssertThrowsError(try XCConfig.Line(lineString: includeString, allowSpacesAfterSharp: false, allowNoSpacesAfterInclude: false))
		}
		
		do {
			let includeString = #"#include?"hello""#
			XCTAssertNoThrow(try XCConfig.Line(lineString: includeString, allowSpacesAfterSharp: true, allowNoSpacesAfterInclude: true))
			XCTAssertNoThrow(try XCConfig.Line(lineString: includeString, allowSpacesAfterSharp: false, allowNoSpacesAfterInclude: true))
			XCTAssertThrowsError(try XCConfig.Line(lineString: includeString, allowSpacesAfterSharp: true, allowNoSpacesAfterInclude: false))
			XCTAssertThrowsError(try XCConfig.Line(lineString: includeString, allowSpacesAfterSharp: false, allowNoSpacesAfterInclude: false))
		}
		
		do {
			let includeString = #"#include? "hello""#
			XCTAssertNoThrow(try XCConfig.Line(lineString: includeString, allowSpacesAfterSharp: true, allowNoSpacesAfterInclude: true))
			XCTAssertNoThrow(try XCConfig.Line(lineString: includeString, allowSpacesAfterSharp: true, allowNoSpacesAfterInclude: false))
			XCTAssertNoThrow(try XCConfig.Line(lineString: includeString, allowSpacesAfterSharp: false, allowNoSpacesAfterInclude: true))
			XCTAssertNoThrow(try XCConfig.Line(lineString: includeString, allowSpacesAfterSharp: false, allowNoSpacesAfterInclude: false))
		}
	}
	
	func testWeirdSpacings() throws {
		do {let testString = "\t  ";                                                XCTAssertEqual(testString, try XCConfig.Line(lineString: testString).lineString())}
		do {let testString = " \t TEST_LINE_PARSING =hello";                        XCTAssertEqual(testString, try XCConfig.Line(lineString: testString).lineString())}
		do {let testString = "\t TEST_LINE_PARSING2\t=\t\thello\t// comment";       XCTAssertEqual(testString, try XCConfig.Line(lineString: testString).lineString())}
		do {let testString = "\t TEST_LINE_PARSING3 =\thello\t  // comment// sd  "; XCTAssertEqual(testString, try XCConfig.Line(lineString: testString).lineString())}
		do {let testString = "TEST_LINE_PARSING4=hello// comment\t// sd\t\t";       XCTAssertEqual(testString, try XCConfig.Line(lineString: testString).lineString())}
		do {let testString = "TEST_LINE_PARSING5=//";                               XCTAssertEqual(testString, try XCConfig.Line(lineString: testString).lineString())}
	}
	
}
