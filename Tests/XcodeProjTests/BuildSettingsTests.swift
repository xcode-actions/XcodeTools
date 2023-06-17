import Foundation
import XCTest

import CommonForTests

@testable import XcodeProj



final class BuildSettingsTests : XCTestCase {
	
	override class func setUp() {
		super.setUp()
		bootstrapIfNeeded()
	}
	
	func testNoParameters() throws {
		XCTAssertEqual(try BuildSettingKey(serializedKey: "SETTING = VALUE").serialized, "SETTING = VALUE")
	}
	
	func testParameterParsingWithComma() throws {
		let actual = BuildSettings(rawBuildSettings: ["MY_BUILD_SETTING[skd=*,arch=*][variant=debug]": ""], allowCommaSeparatorForParameters: true)
		let expected1 = BuildSettings(rawBuildSettings: ["MY_BUILD_SETTING[skd=*][arch=*][variant=debug]": ""], allowCommaSeparatorForParameters: true)
		let expected2 = BuildSettings(rawBuildSettings: ["MY_BUILD_SETTING[skd=*][arch=*][variant=debug]": ""], allowCommaSeparatorForParameters: false)
		compareBuildSettings(expected1, actual)
		compareBuildSettings(expected2, actual)
		
		XCTAssertEqual(actual.settings.first?.value.key.serialized, "MY_BUILD_SETTING[skd=*,arch=*][variant=debug]")
		XCTAssertEqual(expected1.settings.first?.value.key.serialized, "MY_BUILD_SETTING[skd=*][arch=*][variant=debug]")
		XCTAssertEqual(expected2.settings.first?.value.key.serialized, "MY_BUILD_SETTING[skd=*][arch=*][variant=debug]")
	}
	
	func testParameterParsingFailWithoutComma() throws {
		let expected = BuildSettings(rawBuildSettings: ["MY_BUILD_SETTING[skd=*]": ""], allowCommaSeparatorForParameters: false)
		/* We stop the parsing after the closing bracket because we consider the partially formed param is fully invalid,
		 * even though we parse allowing the use of comma to separate parameters.
		 * This is debatable; we could say we parse as much as we can, but that not what we decided. */
		let actual = BuildSettings(rawBuildSettings: ["MY_BUILD_SETTING[skd=*][arch=*,this_is_junk": ""], allowCommaSeparatorForParameters: false)
		XCTAssertEqual(actual.settings.first?.value.key.garbage, "[arch=*,this_is_junk")
		compareBuildSettings(expected, actual)
		
		XCTAssertEqual(actual.settings.first?.value.key.serialized, "MY_BUILD_SETTING[skd=*][arch=*,this_is_junk")
	}
	
	func testParameterParsingFailWithComma() throws {
		let expected = BuildSettings(rawBuildSettings: ["MY_BUILD_SETTING[skd=*]": ""], allowCommaSeparatorForParameters: true)
		let actual = BuildSettings(rawBuildSettings: ["MY_BUILD_SETTING[skd=*][arch=*,this_is_junk": ""], allowCommaSeparatorForParameters: true)
		XCTAssertEqual(actual.settings.first?.value.key.garbage, "[arch=*,this_is_junk")
		compareBuildSettings(expected, actual)
		
		XCTAssertEqual(actual.settings.first?.value.key.serialized, "MY_BUILD_SETTING[skd=*][arch=*,this_is_junk")
	}
	
	private func compareBuildSettings(_ s1: BuildSettings, _ s2: BuildSettings) {
		XCTAssertEqual(s1.settings.map{ $0.value.key }, s2.settings.map{ $0.value.key })
	}
	
}
