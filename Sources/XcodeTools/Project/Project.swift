import Foundation

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
	
	public func getTargets() throws -> [Target] {
		switch self {
			case .xcodeproj(let proj):
				var res = [Target]()
				try proj.managedObjectContext.performAndWait{
					res.append(contentsOf: try proj.pbxproj.rootObject.getTargets().map{ target in
						.xcodeTarget(targetID: target.objectID, project: proj)
					})
					try proj.pbxproj.rootObject.unsafeIterateReferencedSPMProjects(xcodeprojURL: proj.xcodeprojURL, spmCache: proj.spmCache){ spm in
						res.append(contentsOf: spm.targets.map{ .spmTarget($0, project: spm) })
					}
					if !(proj.pbxproj.rootObject.packageReferences?.isEmpty ?? true) {
						Conf.logger?.warning("Loading external SPM dependencies is not supported.")
					}
				}
#warning("TODO: Embedded xcodeprojs")
				return res
				
			case .spm(let spm):
				return spm.targets.map{ .spmTarget($0, project: spm) }
		}
	}
	
	public func getDependents(of target: Target) throws -> Set<Target> {
		let allTargets = try Array(Set(getTargets()).subtracting([target]))
		let targetDeps = try allTargets.map{ try $0.getRecursiveDependencies() }
		let allTargetsWithDeps = zip(allTargets, targetDeps)
		return Set(allTargetsWithDeps.filter{ $0.1.contains(target) }.map{ $0.0 })
	}
	
}
