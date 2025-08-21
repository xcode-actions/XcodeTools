import CoreData
import Foundation

import GlobalConfModule

import SPMProj



extension XcodeProj {
	
	/**
	 Finds file reference of type “wrapper” in the project.
	 If the wrapper is a valid SPM package (an ``SPMProj`` object can be created from the URL), it is passed to you in the handler. */
	public func iterateReferencedSPMProjects(_ handler: (_ proj: SPMProj) async throws -> Void) async throws {
		let referencedFiles = try getReferencedFiles()
		try await iterateReferencedSPMProjects(from: referencedFiles, handler)
	}
	
	public func iterateReferencedSPMTargets(targetNameFilter: Set<String> = [], _ handler: (_ proj: SPMProj, _ target: SPMTarget) async throws -> Void) async throws {
		try await iterateReferencedSPMProjects{ spmProj in
			for t in (spmProj.targets.filter{ targetNameFilter.isEmpty || targetNameFilter.contains($0.name) }) {
				try await handler(spmProj, t)
			}
		}
	}
	
	/** Iterate the SPM targets _referenced in the xcodeproj_ (in a group or folder, not as a global package dependency), which contain a target whose name matches the given target name. */
	public func iterateReferencedSPMTargets(of targetName: String, _ handler: (_ proj: SPMProj, _ target: SPMTarget) async throws -> Void) async throws {
		let (spmTargetsFilterSet, referencedFiles) = try managedObjectContext.performAndWait{
			let spmTargetsFilter = try pbxproj.rootObject.getTargets()
				.filter{ try $0.getName() == targetName } /* We could’ve made a fetch request to replace this line and the ones above, and potentially the next one too… */
				.flatMap{ try $0.getDependencies().compactMap{ try $0.productRef?.getProductName() } }
			
			let referencedFiles = try onContext_getReferencedFiles()
			
			return (Set(spmTargetsFilter), referencedFiles)
		}
		
		guard !spmTargetsFilterSet.isEmpty else {return}
		try await iterateReferencedSPMProjects(from: referencedFiles){ spmProj in
			for t in (spmProj.targets.filter{ spmTargetsFilterSet.contains($0.name) }) {
				try await handler(spmProj, t)
			}
		}
	}
	
	public func getReferencedSPMTarget(named targetName: String) async throws -> (SPMProj, SPMTarget)? {
		var res = [(SPMProj, SPMTarget)]()
		try await iterateReferencedSPMTargets(targetNameFilter: [targetName], { res.append(($0, $1)) })
		guard res.count < 2 else {
			throw Err.multipleMatchingSPMTargetsFound(res)
		}
		return res.first
	}
	
	/* *******
	   MARK: -
	   ******* */
	
	/**
	 Allows iterating on the SPM projects of the XcodeProj outside of the context (because on the context we _cannot_ be async with modern CoreData).
	 
	 The first argument must be retrieved on context using ``onContext_getReferencedFiles()`` or can be retrieved outside of the context using ``getReferencedFiles()``. */
	public func iterateReferencedSPMProjects(from referencedFiles: [(URL, String?)], _ handler: (_ proj: SPMProj) async throws -> Void) async throws {
		for (url, type) in referencedFiles {
			guard type == "wrapper" || type == "folder" else {continue}
			let workspaceRoot = FileManager.default.temporaryDirectory.appendingPathComponent(xcodeprojURL.deletingPathExtension().lastPathComponent).appendingPathComponent(url.lastPathComponent)
			guard let spmProj = try? await spmCache.getProj(for: url, workspaceRoot: workspaceRoot) else {
				if type == "wrapper" {
					/* We only log for the wrapper type; it is normal for folders not to be SPM projects, but some are anyway (and Xcode forgets to update their last known type). */
					Conf.logger?.info("Found invalid SPM project at path \(url.path) in project at path \(xcodeprojURL.path)")
				}
				continue
			}
			try await handler(spmProj)
		}
	}
	
}
