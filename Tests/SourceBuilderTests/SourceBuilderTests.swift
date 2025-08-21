import Crypto
import Foundation
import SystemPackage
import XCTest

import CLTLogger
import Logging

import Utils

import CommonForTests

@testable import SourceBuilder



final class SourceBuilderTests : XCTestCase {
	
	/* Why, oh why this is not throwing? idk. */
	override class func setUp() {
		super.setUp()
		bootstrapIfNeeded()
	}
	
	func testDownloadFile() throws {
		/* While swift on Linux does not have proper async support in XCTest, we
		 * have to put the LINUXASYNC blocks. When Linux is ok, we’ll simply
		 * remove these blocks and make the test async. */
		/* LINUXASYNC START --------- */
		let group = DispatchGroup()
		group.enter()
		Task{do{
			/* LINUXASYNC STOP --------- */
			
			let tmpFolder = FilePath(FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString))!
			let expectedDestinationFile = tmpFolder.appending("constant.txt")
			defer {_ = try? FileManager.default.ensureDirectoryDeleted(path: tmpFolder)}
			
			try FileManager.default.ensureDirectory(path: tmpFolder)
			
			let downloadPhase = try DownloadFilePhase(
				urlTemplate: "https://{{ host }}/constant.{{ extension }}", variables: ["host": "frostland.fr", "extension": "txt"],
				destinationFolder: tmpFolder, expectedHash: ("73475cb40a568e8da8a045ced110137e159f890ac4da883b6b17dc651b3a8049", AnyHasher(t: SHA256.self))
			)
			let skip1 = try await downloadPhase.canBeSkipped; XCTAssertFalse(skip1)
			
			let files = try await downloadPhase.execute();    XCTAssertEqual(files, [expectedDestinationFile])
			let skip2 = try await downloadPhase.canBeSkipped; XCTAssertTrue(skip2)
			
			try Data().write(to: expectedDestinationFile.url)
			let skip3 = try await downloadPhase.canBeSkipped; XCTAssertFalse(skip3)
			
			_ = try await downloadPhase.execute()
			let skip4 = try await downloadPhase.canBeSkipped; XCTAssertTrue(skip4)
			
			/* LINUXASYNC START --------- */
			group.leave()
		} catch {XCTFail("Error thrown during async test: \(error)"); group.leave()}}
		group.wait()
		/* LINUXASYNC STOP --------- */
	}
	
	func testUntar() async throws {
		XCTAssertThrowsError(try UntarPhase(unarchivedFile: "/a/b/c"))
		XCTAssertEqual(try UntarPhase(unarchivedFile: "/a/b/c.tgz").destinationFolder,     FilePath("/a/b/c"))
		XCTAssertEqual(try UntarPhase(unarchivedFile: "/a/b/c.tar.gz").destinationFolder,  FilePath("/a/b/c"))
		XCTAssertEqual(try UntarPhase(unarchivedFile: "/a/b/c.tar.bz2").destinationFolder, FilePath("/a/b/c"))
		XCTAssertEqual(try UntarPhase(unarchivedFile: "/a/b/c.tar.bob").destinationFolder, FilePath("/a/b/c"))
		XCTAssertEqual(try UntarPhase(unarchivedFile: "/a/b/c.1.bob").destinationFolder,   FilePath("/a/b/c.1"))
		
		do {
			let archiveName = "test-0.1.tar.bz2"
			let tmpFolder = FilePath(FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString))!
			let tmpArchivePath = tmpFolder.appending(archiveName)
			defer {_ = try? FileManager.default.ensureDirectoryDeleted(path: tmpFolder)}
			try FileManager.default.ensureDirectory(path: tmpFolder)
			try FileManager.default.copyItem(at: Self.filesPath.appending(archiveName).url, to: tmpArchivePath.url)
			
			let tarPhase = try UntarPhase(unarchivedFile: tmpArchivePath, stripComponents: 1, verifyNoLostFilesFromStrip: true)
			let r1 = try await tarPhase.execute()
			XCTAssertFalse(r1.isEmpty)
			for f in r1 {
				var isDir = ObjCBool(false)
				let path = try XCTUnwrap(tarPhase.destinationFolder.lexicallyResolving(f))
				XCTAssert(FileManager.default.fileExists(atPath: path.string, isDirectory: &isDir))
				XCTAssertFalse(isDir.boolValue)
			}
			let r2 = try await tarPhase.execute()
			XCTAssertEqual(r1, r2)
		}
	}
	
}
