#!/usr/bin/env swift

/* Usage 1: Replace calling `swift` w/ this script.
 * Example:
 *    ./Scripts/xcswift.swift build -c release
 *
 * Usage 2: Just prepare the repo for being tagged: process the model and do nothing else.
 *    ./Scripts/xcswift.swift --- */

import Foundation


struct SimpleError : Error, CustomStringConvertible {
	var message: String
	var description: String {message}
}


var hasBackedUpPackageFile = false

enum CleanupInfo {
	
	static var processes = [Process]()
	
	static var toDelete = Set<URL>()
	static var toMoveBack = Array<(source: URL, destination: URL)>()
	
}


func shell(_ prog: String, _ args: String...) throws {
	try shell(prog, args)
}

func shell(_ prog: String, _ args: [String]) throws {
	let task = Process()
	task.launchPath = "/usr/bin/env"
	task.arguments = [prog] + args
	
	CleanupInfo.processes.append(task)
	task.launch()
	task.waitUntilExit()
	
	guard task.terminationReason == .exit else {
		throw SimpleError(message: "\(prog) was interrupted (was launched w/ args \(args))")
	}
	guard task.terminationStatus == 0 else {
		throw SimpleError(message: "\(prog) did not exit w/ status 0 (was launched w/ args \(args))")
	}
}


func setupCleanupSigaction() throws {
	var newAction = sigaction()
	newAction.sa_flags = 0
	sigemptyset(&newAction.sa_mask)
	newAction.__sigaction_u.__sa_handler = { signal in
		/* In theory we shouldn’t handle the cleanup in the handler directly, but here we won’t care…
		 * Using swift-signal-handling wouldv’e been handy! */
		waitForProcessesAndCleanup(fromSignal: true)
		exit(signal)
	}
	sigaction(2,  &newAction, nil)
	sigaction(15, &newAction, nil)
}


func waitForProcessesAndCleanup(fromSignal: Bool) {
	if fromSignal {
		_ = try? FileHandle.standardError.write(contentsOf: Data("\n***** SIGNAL CAUGHT\nCleaning up...\n".utf8))
	}
	
	let fm = FileManager.default
	
	for p in CleanupInfo.processes {
		/* We’ll assume the process has had time to be launched.
		 * (There is race possible where the interrupt is caught after the process was added to the list but before it was launched.
		 *  But if we go that way, there is also a possibility the interrupt was caught when the list was in the process of being modified,
		 *  thus being invalid in memory, so………
		 *  But we do not really care about all of that in a script, do we?) */
		if p.isRunning {
			_ = try? FileHandle.standardError.write(contentsOf: Data("Killing sub-process pid \(p.processIdentifier)\n".utf8))
			kill(p.processIdentifier, 15)
		}
		p.waitUntilExit()
	}
	
	for p in CleanupInfo.toDelete {
		do    {try fm.removeItem(at: p)}
		catch {_ = try? FileHandle.standardError.write(contentsOf: Data("Error in delete cleanup: \(error)\n".utf8))}
	}
	
	for (source, dest) in CleanupInfo.toMoveBack {
		_ = try? fm.removeItem(at: dest)
		do    {try fm.moveItem(at: source, to: dest)}
		catch {_ = try? FileHandle.standardError.write(contentsOf: Data("Error in move back cleanup: \(error)\n".utf8))}
	}
}


func processModel(xcdatamodeldURL: URL, moduleName: String, tokenInPackageFile: String) throws {
	let fm = FileManager.default
	
	let baseName = xcdatamodeldURL.deletingPathExtension().lastPathComponent
	let generatedArtifactsFolder = xcdatamodeldURL.deletingLastPathComponent().appendingPathComponent("CoreDataModelArtifacts_\(baseName)")
	let compiledModelDestination = generatedArtifactsFolder.appendingPathComponent(baseName).appendingPathExtension("momd")
	guard !fm.fileExists(atPath: generatedArtifactsFolder.path) else {
		throw SimpleError(message: "\(generatedArtifactsFolder.path) already exists; not overwriting")
	}
	
	CleanupInfo.toDelete.insert(generatedArtifactsFolder)
	try fm.createDirectory(at: generatedArtifactsFolder, withIntermediateDirectories: true)
	
	/* Generate CoreData artifacts */
	try shell(
		"xcrun", "momc",
		"--action", "generate", "--swift-version", "5",
		"--macosx-deployment-target", "10.15",
		"--module", "XcodeTools_\(moduleName)",
		"\(xcdatamodeldURL.absoluteURL.path)",
		"\(generatedArtifactsFolder.absoluteURL.path)"
	)
	try shell(
		"xcrun", "momc",
		"--action", "compile",
		"--macosx-deployment-target", "10.15",
		"--module", "XcodeTools_\(moduleName)",
		"\(xcdatamodeldURL.absoluteURL.path)",
		"\(generatedArtifactsFolder.absoluteURL.path)"
	)
	
	/* Tweak Package.swift */
	let packageURL = URL(fileURLWithPath: "Package.swift")
	if !hasBackedUpPackageFile {
		/* First let’s make a backup of the Package.swift file.
		 * We assume we won’t have a file already created at given random UUID path… */
		let dest = fm.temporaryDirectory.appendingPathComponent(UUID().uuidString)
		
		CleanupInfo.toMoveBack.append((source: dest.absoluteURL, destination: packageURL.absoluteURL))
		try fm.copyItem(at: packageURL, to: dest)
		hasBackedUpPackageFile = true
	}
	let modifiedPackage = try String(contentsOf: packageURL).split(separator: "\n", omittingEmptySubsequences: false).map{ line in
		if !line.contains(tokenInPackageFile) {return String(line)}
		else                                  {return #"\#t\#t.copy("\#(generatedArtifactsFolder.lastPathComponent)/\#(compiledModelDestination.lastPathComponent)")"#}
	}.joined(separator: "\n")
	try Data(modifiedPackage.utf8).write(to: packageURL)
	
	/* Finally, move the xcdatamodeld file away (once again, we assume we won’t get a collision on the destination file name). */
	let dest = fm.temporaryDirectory.appendingPathComponent(UUID().uuidString)
	CleanupInfo.toMoveBack.append((source: dest.absoluteURL, destination: xcdatamodeldURL.absoluteURL))
	try fm.moveItem(at: xcdatamodeldURL, to: dest)
}


do {
	try setupCleanupSigaction()
	
	let fm = FileManager.default
	/* cd to package root so the script can be launched from wherever */
	fm.changeCurrentDirectoryPath(URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent().path)
	
	/* Process the models (only one model for now) */
	try processModel(xcdatamodeldURL: URL(fileURLWithPath: "./Sources/XcodeProj/PBXModel.xcdatamodeld"), moduleName: "XcodeProj", tokenInPackageFile: "__COREDATA_TOKEN_XcodeProj_PBXModel")
	
	guard CommandLine.arguments.count != 2 || CommandLine.arguments[1] != "---" else {
		/* We do nothing, we just want the model processed. */
		exit(0)
	}
	
	/* Run swift */
	try shell("swift", Array(CommandLine.arguments.dropFirst()))
	waitForProcessesAndCleanup(fromSignal: false)
} catch {
	_ = try? FileHandle.standardError.write(contentsOf: Data("Error: \(error)\n".utf8))
	waitForProcessesAndCleanup(fromSignal: false)
	exit(1)
}
