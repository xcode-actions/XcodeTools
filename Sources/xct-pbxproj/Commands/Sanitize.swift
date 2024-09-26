import Foundation

/* I cannot update ArgumentParser because of swift-driver… */
@preconcurrency import ArgumentParser
import XcodeProj



struct Sanitize : ParsableCommand {
	
	static let configuration = CommandConfiguration(
		abstract: "Sanitize a pbxproj.",
		discussion: """
			Actions for the whole project:
			   - Sort the packages dependencies.
			
			Actions for each targets:
			   - Sort the target dependencies;
			   - Sort the package product dependencies;
			   - Sort the build files in the build phases.
			"""
	)
	
	@OptionGroup
	var xctPbxprojOptions: XctPbxproj.Options
	
	func run() throws {
		XctPbxproj.bootstrap()
		let logger = XctPbxproj.logger
		
		
		let xcodeproj = try XcodeProj(path: xctPbxprojOptions.pathToXcodeproj)
		let context = xcodeproj.managedObjectContext
		try context.performAndWait{
			var modified = false
			
			/* Sort the package references. */
			let ids = xcodeproj.pbxproj.rootObject.packageReferences?.map{ $0.objectID }
			try xcodeproj.pbxproj.rootObject.packageReferences = xcodeproj.pbxproj.rootObject.packageReferences?.sorted{ ref1, ref2 in
				try ref1.getPackageName().localizedCaseInsensitiveCompare(ref2.getPackageName()) == .orderedAscending
			}
			modified = (modified || ids != xcodeproj.pbxproj.rootObject.packageReferences?.map{ $0.objectID })
			
			try xcodeproj.pbxproj.rootObject.getTargets().forEach{ target in
				/* Sort the build files in the build phases. */
				target.buildPhases?.forEach{ buildPhase in
					let ids = buildPhase.files?.map{ $0.objectID }
					buildPhase.files = buildPhase.files?.sorted{ buildFile1, buildFile2 in
						(buildFile1.itemName ?? "").localizedCaseInsensitiveCompare(buildFile2.itemName ?? "") == .orderedAscending
					}
					modified = (modified || ids != buildPhase.files?.map{ $0.objectID })
				}
				/* Sort the package product dependencies. */
				do {
					let ids = (target as? PBXNativeTarget)?.packageProductDependencies?.map{ $0.objectID }
					(target as? PBXNativeTarget)?.packageProductDependencies = try (target as? PBXNativeTarget)?.packageProductDependencies?.sorted{ dep1, dep2 in
						try dep1.getProductName().localizedCaseInsensitiveCompare(dep2.getProductName()) == .orderedAscending
					}
					modified = (modified || ids != (target as? PBXNativeTarget)?.packageProductDependencies?.map{ $0.objectID })
				}
				/* Sort the dependencies. */
				do {
					let ids = target.dependencies?.map{ $0.objectID }
					target.dependencies = try target.dependencies?.sorted{ dep1, dep2 in
						try dep1.getVisibleName().localizedCaseInsensitiveCompare(dep2.getVisibleName()) == .orderedAscending
					}
					modified = (modified || ids != target.dependencies?.map{ $0.objectID })
				}
			}
			
			try context.save()
			if modified {
				logger.info("Rewriting pbxproj")
				try Data(xcodeproj.pbxproj.stringSerialization(projectName: xcodeproj.projectName).utf8).write(to: xcodeproj.pbxprojURL)
			} else {
				logger.info("No modifications in the pbxproj")
			}
		}
	}
	
}
