import Foundation
import SystemPackage

import ArgumentParser
import CLTLogger
import Logging
import SafeGlobal
import StreamReader

import ProcessInvocation
import XcodeJsonOutput
import XcodeTools



/* Big up to <https://github.com/jjrscott/XcodeBuildResultStream>. */
@main
struct XctBuild : AsyncParsableCommand {
	
	static let execPathEnvVarName = "XCT_EXEC_PATH"
	
	static let configuration = CommandConfiguration(
		abstract: "Build an Xcode project",
		discussion: "Hopefully, the options supported by this tool are easier to understand than xcodebuild’s."
	)
	
	@SafeGlobal
	static var logger: Logger = {
		var ret = Logger(label: "main")
		ret.logLevel = .debug
		return ret
	}()
	
	/* We cannot specify an empty extension in the completion kind, otherwise it would only match files ending with a dot. */
	@Option(completion: .file())
	var xcodebuildPath: String = "/usr/bin/xcodebuild"
	
	/* TODO: For now only one scheme only. Later multiple schemes? */
	@Option
	var scheme: String
	
	func run() async throws {
		/* While swift-argument-parser does not compile w/ Xcode on async branch. */
		LoggingSystem.bootstrap{ _ in CLTLogger() }
//		XcodeToolsConfig.logger?.logLevel = .trace
		XctBuild.logger.logLevel = .trace
		
		let (fdXcodeReadOutput, fdXcodeWriteOutput) = try ProcessInvocation.unownedPipe()
		guard let outputFdComponent = FilePath.Component(String(fdXcodeWriteOutput.rawValue)) else {
			/* TODO: Error */
			throw NSError(domain: "yo", code: 1, userInfo: nil)
		}
		
		let resultBundlePath = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("xcresult").path
		let resultStreamPath: FilePath = FilePath(root: "/", components: "dev", "fd", outputFdComponent)
		
		let args = [
			"-verbose",// "-json",
			"-disableAutomaticPackageResolution",
			"-scheme", scheme,
			"-resultBundlePath", resultBundlePath,
			"-resultStreamPath", resultStreamPath.string
		]
		let pi = ProcessInvocation(
			"/usr/bin/xcodebuild", args: args,
			fileDescriptorsToSend: [fdXcodeWriteOutput: fdXcodeWriteOutput],
			additionalOutputFileDescriptors: [fdXcodeReadOutput]
		)
		for try await lfd in pi {
			switch lfd.fd {
				case fdXcodeReadOutput:
//					XctBuild.logger.trace("json: \(strLineWithSource.line)")
					guard let streamedEvent = try Parser.parse(json: lfd.line) as? StreamedEvent else {
						/* TODO: Error */
						throw NSError(domain: "yo", code: 1, userInfo: nil)
					}
					if let readable = streamedEvent.structuredPayload.humanReadableEvent(withColors: false) {
						print(readable)
					} else {
//						XctBuild.logger.trace("skipped streamed event w/ no human readable description: \(streamedEvent)")
					}
					
				default:
					guard let lineStr = try? lfd.strLine(encoding: .utf8) else {
						XctBuild.logger.error("invalid non-utf8 line from xcodebuild on fd \(lfd.fd.rawValue): \(lfd.line.reduce("", { $0 + String(format: "%02x", $1) }))")
						continue
					}
					let level: Logger.Level
					if lfd.fd == .standardOutput {level = .info}
					else                         {level = .warning}
					XctBuild.logger.log(level: level, "xcodebuild output on fd \(lfd.fd.rawValue): \(lineStr)")
			}
		}
	}
	
}
