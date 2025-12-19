import Foundation

import ArgumentParser
import XcodeProj



struct SetMarketingVersion : ParsableCommand {
	
	@OptionGroup
	var xctVersionsOptions: XctVersions.Options
	
	@OptionGroup
	var setVersionOptions: SetVersion.Options
	
	@Argument
	var newVersion: String
	
	func run() throws {
		let xcodeproj = try XcodeProj(path: xctVersionsOptions.pathToXcodeproj, autodetectInFolderAtPath: ".")
		do {
			try SetVersion.setVersion(
				options: setVersionOptions, generalOptions: xctVersionsOptions,
				newVersion: newVersion,
				xcodeproj: xcodeproj,
				plistKey: "CFBundleShortVersionString",
				buildSettingKey: "MARKETING_VERSION"
			)
		} catch {
#warning("Evil NSLog!")
			NSLog("%@", "There was an error setting the version of the project. Some files might have been modified.")
			throw error
		}
	}
	
}
