import Foundation

import CollectionConcurrencyKit
import GlobalConfModule
import SPMProj
import XcodeProj



public enum Project {
	
	case xcodeproj(XcodeProj)
//	case xcworkspace(XcodeWorkspace)
	case spm(SPMProj)
	
	public init(xcodeprojPath: String?, autodetectInFolderAtPath autodetectFolder: String = ".") throws {
		try self = .xcodeproj(XcodeProj(path: xcodeprojPath, autodetectInFolderAtPath: autodetectFolder))
	}
	
	public init(xcodeprojURL: URL) throws {
		try self = .xcodeproj(XcodeProj(xcodeprojURL: xcodeprojURL))
	}
	
	public func getTargets() async throws -> [Target] {
		switch self {
			case .xcodeproj(let proj):
				let (partialRes, referencedFiles) = try await proj.managedObjectContext.perform{
					let partialRes: [Target] = try proj.pbxproj.rootObject.getTargets().map{ target in
						.xcodeTarget(targetID: target.objectID, project: proj)
					}
					let referencedFiles = try proj.onContext_getReferencedFiles()
					if !(proj.pbxproj.rootObject.packageReferences?.isEmpty ?? true) {
						Conf.logger?.warning("Loading external SPM dependencies is not supported.")
					}
					return (partialRes, referencedFiles)
				}
				var res = partialRes
				try await proj.iterateReferencedSPMProjects(from: referencedFiles){ spm in
					res.append(contentsOf: spm.targets.map{ .spmTarget($0, project: spm) })
				}
#warning("TODO: Embedded xcodeprojs")
				return res
				
			case .spm(let spm):
				return spm.targets.map{ .spmTarget($0, project: spm) }
		}
	}
	
	public func getDependents(of target: Target) async throws -> Set<Target> {
		let allTargets = try await Array(Set(getTargets()).subtracting([target]))
		let targetDeps = try await allTargets.concurrentMap{ try await $0.getRecursiveDependencies() }
		let allTargetsWithDeps = zip(allTargets, targetDeps)
		return Set(allTargetsWithDeps.filter{ $0.1.contains(target) }.map{ $0.0 })
	}
	
}
