import Foundation
import XCTest

import CommonForTests

@testable import XcodeProj



final class TestsProject1 : XCTestCase {
	
	override class func setUp() {
		super.setUp()
		bootstrapIfNeeded()
	}
	
	static let xcodeprojURL = testsDataURL.appendingPathComponent("project1").appendingPathComponent("Project 1.xcodeproj")
	
	func testReserialization() throws {
		let xcodeproj = try XcodeProj(xcodeprojURL: Self.xcodeprojURL)
		let originalContents = try Data(contentsOf: xcodeproj.pbxprojURL)
		try XCTAssertEqual(originalContents, Data(xcodeproj.pbxproj.stringSerialization(projectName: xcodeproj.projectName).utf8))
		
		/* Uncomment to see the diff using git. */
//		try Data(xcodeproj.pbxproj.stringSerialization(projectName: xcodeproj.projectName).utf8).write(to: xcodeproj.pbxprojURL)
	}
	
	func testFileElementPaths() throws {
		let xcodeproj = try XcodeProj(xcodeprojURL: Self.xcodeprojURL)
		
		let standardSettings = try BuildSettings.standardDefaultSettingsForResolvingPathsAsDictionary(xcodeprojURL: Self.xcodeprojURL)
		try xcodeproj.managedObjectContext.performAndWait{
			let fetchRequest: NSFetchRequest<PBXFileElement> = NSFetchRequest(entityName: "PBXFileElement")
			try xcodeproj.managedObjectContext.fetch(fetchRequest).forEach{
				XCTAssertNoThrow(try $0.resolvedPathAsURL(xcodeprojURL: Self.xcodeprojURL, variables: standardSettings))
			}
		}
	}
	
	func testXcodeprojAndPlist() throws {
		let xcodeproj = try XcodeProj(xcodeprojURL: Self.xcodeprojURL)
		try xcodeproj.iterateCombinedBuildSettingsOfTargets{ target, targetName, configuration, configurationName, combinedBuildSettings in
			guard targetName == "Target 1" && configurationName == "Debug" else {
				return
			}
			XCTAssertEqual(combinedBuildSettings["TEST_EMBEDDED"], #"one"#)
			XCTAssertEqual(combinedBuildSettings["TEST_IMPORTED_DEV_DIR"], #"LOCAL"#)
			XCTAssertEqual(combinedBuildSettings["TEST_IMPORTED_SRCROOT"], #"UNRESOLVED"#)
			XCTAssertEqual(combinedBuildSettings["TEST_INCLUDES"], #" test3 test2 test3 test test3 test2 test3 test"#)
			XCTAssertEqual(combinedBuildSettings["TEST_INCLUDES_2"], #" test3 test2 test3 test test3 test2 test3 test"#)
			XCTAssertEqual(combinedBuildSettings["TEST_INHERIT_NO_PARENTHESIS"], #"yo yo"#)
			XCTAssertEqual(combinedBuildSettings["TEST_INVALID_EMBEDDED_1"], #"one"#)
			XCTAssertEqual(combinedBuildSettings["TEST_INVALID_EMBEDDED_2"], #"one"#)
			XCTAssertEqual(combinedBuildSettings["TEST_QUOTES"], #"";""#)
			XCTAssertEqual(combinedBuildSettings["TEST_QUOTES_2"], #"";";s"#)
			XCTAssertEqual(combinedBuildSettings["TEST_QUOTES_3"], #"";";s"#)
			XCTAssertEqual(combinedBuildSettings["TEST_RESOLUTION_ASYMETRIC"], #"prefix "#)
			XCTAssertEqual(combinedBuildSettings["TEST_RESOLUTION_ASYMETRIC2"], #"prefix "#)
			XCTAssertEqual(combinedBuildSettings["TEST_RESOLUTION_DOES_NOT_EXIST"], #"prefix  suffix"#)
			XCTAssertEqual(combinedBuildSettings["TEST_RESOLUTION_DOES_NOT_EXIST_IN_PLIST"], #""#)
			XCTAssertEqual(combinedBuildSettings["TEST_RESOLUTION_LEVEL_UP"], #"prefix Level Up! suffix"#)
			XCTAssertEqual(combinedBuildSettings["TEST_RESOLUTION_NO_PARENTHESIS"], #"prefix hello suffix"#)
			XCTAssertEqual(combinedBuildSettings["TEST_RESOLUTION_NO_PARENTHESIS2"], #"prefix one suffix"#)
			XCTAssertEqual(combinedBuildSettings["TEST_RESOLUTION_NO_PARENTHESIS3"], #"prefix one\#tsuffix"#)
			XCTAssertEqual(combinedBuildSettings["TEST_RESOLUTION_NO_PARENTHESIS4"], #"prefix $VALUE_1suffix"#)
			XCTAssertEqual(combinedBuildSettings["TEST_RESOLUTION_NO_PARENTHESIS5"], #"prefix $DOES_NOT_EXIST suffix"#)
			XCTAssertEqual(combinedBuildSettings["TEST_RESOLUTION_NO_PARENTHESIS6"], #"prefix $VALUE_1 suffix"#)
			XCTAssertEqual(combinedBuildSettings["TEST_RESOLUTION_NO_PARENTHESIS7"], #"prefix $VALUE_1 suffix"#)
			XCTAssertEqual(combinedBuildSettings["TEST_RESOLUTION_OF_VARIANT"], #"prefix  suffix"#)
			XCTAssertEqual(combinedBuildSettings["TEST_SINGLE_DOLLAR"], #"prefix $ suffix"#)
			XCTAssertEqual(combinedBuildSettings["TEST_SPACES"], #""a b"  'a b c'\#t def"#)
			XCTAssertEqual(combinedBuildSettings["TEST_SEMICOLON"], #";2"#)
			XCTAssertEqual(combinedBuildSettings["TEST_DOUBLE_SEMICOLON"], #";"#)
			XCTAssertEqual(combinedBuildSettings["TEST_VARIABLE_1"], #"$(VALUE_1"#)
			XCTAssertEqual(combinedBuildSettings["TEST_VARIABLE_2"], #"//"#)
			/* Variant resolution is not supported yet. */
//			XCTAssertEqual(combinedBuildSettings["TEST_VARIANT"], #"hello4"#)
//			XCTAssertEqual(combinedBuildSettings["TEST_VARIANT_2"], #"hello2"#)
//			XCTAssertEqual(combinedBuildSettings["TEST_VARIANT_3"], #""#)
			
			guard let resolvedPlist = try combinedBuildSettings.infoPlistResolved(xcodeprojURL: Self.xcodeprojURL) else {
				XCTFail("Cannot get plist")
				return
			}
			XCTAssertEqual(resolvedPlist["TEST_EMBEDDED"] as? String, #"one"#)
			XCTAssertEqual(resolvedPlist["TEST_IMPORTED_DEV_DIR"] as? String, #"LOCAL"#)
			XCTAssertEqual(resolvedPlist["TEST_IMPORTED_SRCROOT"] as? String, #"UNRESOLVED"#)
			XCTAssertEqual(resolvedPlist["TEST_INCLUDES"] as? String, #" test3 test2 test3 test test3 test2 test3 test"#)
			XCTAssertEqual(resolvedPlist["TEST_INCLUDES_2"] as? String, #" test3 test2 test3 test test3 test2 test3 test"#)
			XCTAssertEqual(resolvedPlist["TEST_INHERIT_NO_PARENTHESIS"] as? String, #"yo yo"#)
			XCTAssertEqual(resolvedPlist["TEST_INVALID_EMBEDDED_1"] as? String, #"one"#)
			XCTAssertEqual(resolvedPlist["TEST_INVALID_EMBEDDED_2"] as? String, #"one"#)
			XCTAssertEqual(resolvedPlist["TEST_QUOTES"] as? String, #"";""#)
			XCTAssertEqual(resolvedPlist["TEST_QUOTES_2"] as? String, #"";";s"#)
			XCTAssertEqual(resolvedPlist["TEST_QUOTES_3"] as? String, #"";";s"#)
			XCTAssertEqual(resolvedPlist["TEST_RESOLUTION_ASYMETRIC"] as? String, #"prefix "#)
			XCTAssertEqual(resolvedPlist["TEST_RESOLUTION_ASYMETRIC2"] as? String, #"prefix "#)
			XCTAssertEqual(resolvedPlist["TEST_RESOLUTION_ASYMETRIC3"] as? String, #"prefix "#)
			XCTAssertEqual(resolvedPlist["TEST_RESOLUTION_BRACES_IN_PLIST"] as? String, #"me.frizlab.project1"#)
			XCTAssertEqual(resolvedPlist["TEST_RESOLUTION_DOES_NOT_EXIST"] as? String, #"prefix  suffix"#)
			XCTAssertEqual(resolvedPlist["TEST_RESOLUTION_DOES_NOT_EXIST2_IN_PLIST"] as? String, #"$DOES_NOT_EXIST"#)
			XCTAssertEqual(resolvedPlist["TEST_RESOLUTION_DOES_NOT_EXIST_IN_PLIST"] as? String, #""#)
			XCTAssertEqual(resolvedPlist["TEST_RESOLUTION_LEVEL_UP"] as? String, #"prefix Level Up! suffix"#)
			XCTAssertEqual(resolvedPlist["TEST_RESOLUTION_NO_PARENTHESIS"] as? String, #"prefix hello suffix"#)
			XCTAssertEqual(resolvedPlist["TEST_RESOLUTION_NO_PARENTHESIS2"] as? String, #"prefix one suffix"#)
			XCTAssertEqual(resolvedPlist["TEST_RESOLUTION_NO_PARENTHESIS3"] as? String, #"prefix one\#tsuffix"#)
			XCTAssertEqual(resolvedPlist["TEST_RESOLUTION_NO_PARENTHESIS4"] as? String, #"prefix $VALUE_1suffix"#)
			XCTAssertEqual(resolvedPlist["TEST_RESOLUTION_NO_PARENTHESIS5"] as? String, #"prefix $DOES_NOT_EXIST suffix"#)
			XCTAssertEqual(resolvedPlist["TEST_RESOLUTION_NO_PARENTHESIS6"] as? String, #"prefix $VALUE_1 suffix"#)
			XCTAssertEqual(resolvedPlist["TEST_RESOLUTION_NO_PARENTHESIS7"] as? String, #"prefix $VALUE_1 suffix"#)
			XCTAssertEqual(resolvedPlist["TEST_RESOLUTION_OF_VARIANT"] as? String, #"prefix  suffix"#)
			XCTAssertEqual(resolvedPlist["TEST_SINGLE_DOLLAR"] as? String, #"prefix $ suffix"#)
			XCTAssertEqual(resolvedPlist["TEST_SPACES"] as? String, #""a b"  'a b c'\#t def"#)
			XCTAssertEqual(resolvedPlist["TEST_VARIABLE_1"] as? String, #"$(VALUE_1"#)
			XCTAssertEqual(resolvedPlist["TEST_VARIABLE_2"] as? String, #"//"#)
		}
	}
	
}
