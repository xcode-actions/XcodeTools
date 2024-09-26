import CoreData
import Foundation

import GlobalConfModule

import SPMProj



extension XcodeProj {
	
	/**
	 Finds file reference of type “wrapper” in the project.
	 If the wrapper is a valid SPM package (an ``SPMProj`` object can be created from the URL), it is passed to you in the handler. */
	public func iterateReferencedSPMProjects(_ handler: (_ proj: SPMProj) throws -> Void) throws {
		try managedObjectContext.performAndWait{
			try pbxproj.rootObject.unsafeIterateReferencedSPMProjects(xcodeprojURL: xcodeprojURL, spmCache: spmCache, handler)
		}
	}
	
	public func iterateReferencedSPMTargets(_ handler: (_ proj: SPMProj, _ target: SPMTarget) throws -> Void) throws {
		try managedObjectContext.performAndWait{
			try pbxproj.rootObject.unsafeIterateReferencedSPMTargets(xcodeprojURL: xcodeprojURL, spmCache: spmCache, handler)
		}
	}
	
	/** Iterate the SPM targets _referenced in the xcodeproj_ (in a group or folder, not as a global package dependency), which contain a target whose name matches the given target name. */
	public func iterateReferencedSPMTargets(of targetName: String, _ handler: (_ proj: SPMProj, _ target: SPMTarget) throws -> Void) throws {
		try managedObjectContext.performAndWait{
			try pbxproj.rootObject.unsafeIterateReferencedSPMTargets(of: targetName, xcodeprojURL: xcodeprojURL, spmCache: spmCache, handler)
		}
	}
	
}


extension PBXProject {
	
	public func unsafeIterateReferencedSPMProjects(xcodeprojURL: URL, spmCache: SPMProjCache, _ handler: (_ proj: SPMProj) throws -> Void) throws {
		try unsafeIterateReferencedFiles(xcodeprojURL: xcodeprojURL){ url, type in
			guard type == "wrapper" || type == "folder" else {return}
			let workspaceRoot = FileManager.default.temporaryDirectory.appendingPathComponent(xcodeprojURL.deletingPathExtension().lastPathComponent).appendingPathComponent(url.lastPathComponent)
			guard let spmProj = try? spmCache.getProj(for: url, workspaceRoot: workspaceRoot) else {
				if type == "wrapper" {
					/* We only log for the wrapper type; it is normal for folders not to be SPM projects, but some are anyway (and Xcode forgets to update their last know type). */
					Conf.logger?.info("Found invalid SPM project at path \(url.path) in project at path \(xcodeprojURL.path)")
				}
				return
			}
			try handler(spmProj)
		}
	}
	
	public func getReferencedSPMTarget(named targetName: String, xcodeprojURL: URL, spmCache: SPMProjCache) throws -> (SPMProj, SPMTarget)? {
		var res = [(SPMProj, SPMTarget)]()
		try unsafeIterateReferencedSPMTargets(targetNameFilter: [targetName], xcodeprojURL: xcodeprojURL, spmCache: spmCache, { res.append(($0, $1)) })
		guard res.count < 2 else {
			throw Err.multipleMatchingSPMTargetsFound(res)
		}
		return res.first
	}
	
	public func unsafeIterateReferencedSPMTargets(targetNameFilter: Set<String> = [], xcodeprojURL: URL, spmCache: SPMProjCache, _ handler: (_ proj: SPMProj, _ target: SPMTarget) throws -> Void) throws {
		try unsafeIterateReferencedSPMProjects(xcodeprojURL: xcodeprojURL, spmCache: spmCache){ spmProj in
			try spmProj.targets.filter{ targetNameFilter.isEmpty || targetNameFilter.contains($0.name) }.forEach{ try handler(spmProj, $0) }
		}
	}
	
	public func unsafeIterateReferencedSPMTargets(of targetName: String, xcodeprojURL: URL, spmCache: SPMProjCache, _ handler: (_ proj: SPMProj, _ target: SPMTarget) throws -> Void) throws {
		let spmTargetsFilter = try getTargets()
			.filter{ try $0.getName() == targetName } /* We could’ve made a fetch request to replace this line and the ones above, and potentially the next one too… */
			.flatMap{ try $0.getDependencies().compactMap{ try $0.productRef?.getProductName() } }
		let spmTargetsFilterSet = Set(spmTargetsFilter)
		
		guard !spmTargetsFilterSet.isEmpty else {return}
		try unsafeIterateReferencedSPMTargets(targetNameFilter: spmTargetsFilterSet, xcodeprojURL: xcodeprojURL, spmCache: spmCache, handler)
	}
	
}
