import CoreData
import Foundation

import SPMProj



extension XcodeProj {
	
	/**
	 Finds file reference of type “wrapper” in the project.
	 If the wrapper is a valid SPM package (an ``SPMProj`` object can be created from the URL), it is passed to you in the handler. */
	public func iterateSPMPackagesInReferencedFile(_ handler: (_ proj: SPMProj) throws -> Void) throws {
		try managedObjectContext.performAndWait{
			try unsafeIterateSPMPackagesInReferencedFile(handler)
		}
	}
	
	public func iterateSPMTargets(of targetName: String, _ handler: (_ proj: SPMProj, _ target: SPMTarget) throws -> Void) throws {
		try managedObjectContext.performAndWait{
			let spmDependencies = try pbxproj.rootObject
				.getTargets()
				.filter{ try $0.getName() == targetName } /* We could’ve made a fetch request to replace this line and the ones above, and potentially the next one too… */
				.flatMap{ try $0.getBuildPhases().compactMap{ $0 as? PBXFrameworksBuildPhase } }
				.flatMap{ try $0.getFiles().compactMap{ try $0.productRef?.getProductName() } }
			
			let spmDependenciesSet = Set(spmDependencies)
			try unsafeIterateSPMPackagesInReferencedFile(targetNameFilter: spmDependenciesSet, { spmProj in
				try spmProj.targets.filter{ spmDependenciesSet.contains($0.name) }.forEach{ try handler(spmProj, $0) }
			})
		}
	}
	
	internal func unsafeIterateSPMPackagesInReferencedFile(targetNameFilter: Set<String> = [], _ handler: (_ proj: SPMProj) throws -> Void) throws {
		try unsafeIterateReferencedFiles{ url, type in
			guard type == "wrapper" || type == "folder" else {return}
			let workspaceRoot = FileManager.default.temporaryDirectory.appendingPathComponent(xcodeprojURL.deletingPathExtension().lastPathComponent).appendingPathComponent(url.lastPathComponent)
			guard let spmProj = try? SPMProj(url: url, workspaceRoot: workspaceRoot) else {
				if type == "wrapper" {
					/* We only log for the wrapper type; it is normal for folders not to be SPM projects, but some are anyway (and Xcode forgets to update their last know type). */
					Conf.logger?.info("Found invalid SPM project at path \(url.path) in project at path \(xcodeprojURL.path)")
				}
				return
			}
			guard targetNameFilter.isEmpty || spmProj.targets.map({ $0.name }).contains(where: { targetNameFilter.contains($0) }) else {
				Conf.logger?.debug("Skipped SPM package by filter: \(url.path)")
				return
			}
			try handler(spmProj)
		}
	}
	
}
