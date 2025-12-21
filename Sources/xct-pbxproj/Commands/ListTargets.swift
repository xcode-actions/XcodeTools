import Foundation

import ArgumentParser
import XcodeProj



struct ListTargets : AsyncParsableCommand {
	
	static let configuration = CommandConfiguration(
		abstract: "List the targets of a pbxproj file."
	)
	
	@OptionGroup
	var xctPbxprojOptions: XctPbxproj.Options
	
	@Flag
	var print0: Bool = false
	
	func run() throws {
		XctPbxproj.bootstrap()
//		let logger = XctPbxproj.logger
		
		
		let xcodeproj = try XcodeProj(path: xctPbxprojOptions.pathToXcodeproj)
		let context = xcodeproj.managedObjectContext
		try context.performAndWait{
			let names = try xcodeproj.pbxproj.rootObject.getTargets().map{ try $0.getName() }
			for name in names {
				print(name, terminator: print0 ? "\0" : "\n")
			}
		}
	}
	
}
