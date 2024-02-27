import Foundation
import XCTest

import ProcessInvocation

import CommonForTests

@testable import SPMProj



final class TestsSPMAssertionFailure : XCTestCase {
	
	override class func setUp() {
		super.setUp()
		bootstrapIfNeeded()
	}
	
	static let testDataArchiveURL = testsDataURL.appendingPathComponent("spm-assert-crash.tar.bz2")
	
	func testResolveDependencies() throws {
		/* First let’s unarchive the data.
		 * This is needed because we have to have a valid git repo… which cannot be commited inside the repo (XcodeTools’)!
		 * So we have archived it instead and we’re unarchiving it before the test. */
		let fm = FileManager.default
		let workdir = fm.temporaryDirectory.appending(component: "xct-spm-assertion-failure-test-\(UUID().uuidString)", directoryHint: .isDirectory)
		try fm.createDirectory(at: workdir, withIntermediateDirectories: true)
		/* We’re using the non-async version of ProcessInvocation’s invoke method because Linux does not support async tests yet…
		 * The test is not run on Linux after all (I forgot…) but I won’t change the invocation now! */
		try? ProcessInvocation("tar", "--strip-components", "1", "-xf", Self.testDataArchiveURL.path(percentEncoded: false), workingDirectory: workdir, stdoutRedirect: .none, stderrRedirect: .none)
			.invoke{ _, _, _ in }.1.wait()
		defer {try? fm.removeItem(at: workdir)}
		
		XCTAssertNoThrow(try SPMProj(url: workdir.appending(path: "root"), workspaceRoot: nil))
	}
	
}
