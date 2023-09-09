import CoreData
import Foundation

import UnwrapOrThrow

import SPMProj
import XcodeProj



public enum Target : Hashable {
	
	case xcodeTarget(targetID: NSManagedObjectID, project: XcodeProj)
	case spmTarget(SPMTarget, project: SPMProj?)
	
	public var spmTarget: SPMTarget? {
		switch self {
			case .xcodeTarget:         return nil
			case .spmTarget(let t, _): return t
		}
	}
	
	public func getName() throws -> String {
		switch self {
			case let .xcodeTarget(targetID, project):
				return try project.managedObjectContext.performAndWait{
					return try unsafeXcodeTargetFromID(targetID, context: project.managedObjectContext).getName()
				}
				
			case let .spmTarget(spmTarget, _):
				return spmTarget.name
		}
	}
	
	public func getSourcesRoot() -> URL? {
		switch self {
			case     .xcodeTarget:             return nil
			case let .spmTarget(spmTarget, _): return spmTarget.sourcesRoot
		}
	}
	
	public func getSources() throws -> [URL] {
		switch self {
			case let .xcodeTarget(targetID, project):
				return try project.managedObjectContext.performAndWait{
					return try unsafeXcodeTargetFromID(targetID, context: project.managedObjectContext)
						.getBuildPhases()
						.lazy
						.compactMap{ $0 as? PBXSourcesBuildPhase }
						.flatMap{ sourcesPhase in
							try sourcesPhase.getFiles().compactMap{ file in
								/* A build file has either a file ref or a product ref. */
								return try file.fileRef?.resolvedPathAsURL(
									xcodeprojURL: project.xcodeprojURL,
									variables: BuildSettings.standardDefaultSettingsForResolvingPathsAsDictionary(xcodeprojURL: project.xcodeprojURL)
								)
							}
						}
				}
				
			case let .spmTarget(spmTarget, _):
				return spmTarget.sources
		}
	}
	
	public func getResources() throws -> [URL] {
		switch self {
			case let .xcodeTarget(targetID, project):
				return try project.managedObjectContext.performAndWait{
					return try unsafeXcodeTargetFromID(targetID, context: project.managedObjectContext)
						.getBuildPhases()
						.lazy
						.compactMap{ $0 as? PBXResourcesBuildPhase }
						.flatMap{ sourcesPhase in
							try sourcesPhase.getFiles().compactMap{ file in
								/* A build file has either a file ref or a product ref. */
								return try file.fileRef?.resolvedPathAsURL(
									xcodeprojURL: project.xcodeprojURL,
									variables: BuildSettings.standardDefaultSettingsForResolvingPathsAsDictionary(xcodeprojURL: project.xcodeprojURL)
								)
							}
						}
				}
				
			case let .spmTarget(spmTarget, _):
				/* TODO: Decide what we do about the “others” part.
				 *       Xcode treats some files as resources (or sources, idk), but SPM do not know about those (xcassets, storyboards, etc.)
				 *       For libSPM they will appear in others if not explicitly declared in resources!
				 *       For now we return everything in resources _and_ others for SPM project; we have to decide what to do next.
				 *       Xcode and most likely SPM will evolve (system of plugins is coming), so I think things will change anyway. */
				return spmTarget.resources + spmTarget.others
		}
	}
	
	public func getDirectDependencies() throws -> Set<Target> {
		return try Set(getExplicitDirectDependencies() + getImplicitDirectDependencies())
	}
	
	public func getExplicitDirectDependencies() throws -> [Target] {
		switch self {
			case let .xcodeTarget(targetID, project):
				return try project.managedObjectContext.performAndWait{
					let xcodeTarget = try unsafeXcodeTargetFromID(targetID, context: project.managedObjectContext)
					let pbxProject = try xcodeTarget.getProject()
					return try xcodeTarget
						.getDependencies()
						.compactMap{ dependency in
							if let target = dependency.target {
								guard try dependency.targetProxy?.getContainerPortalID() == pbxProject.getXcodeID() else {
									throw Err.internalError("Unsupported configuration (TODO) with target proxy pointing to another project.")
								}
								guard dependency.productRef == nil else {
									throw Err.internalError("productRef is non-nil with a non-nil target: AFAIK this is an invalid pbxproj.")
								}
								return .xcodeTarget(targetID: target.objectID, project: project)
							} else if let productRef = dependency.productRef {
								if let _ = productRef.package {
									Conf.logger?.warning("Skipped unsupported external SPM dependency.")
									return nil
								} else {
									let productName = try productRef.getProductName()
									guard let (spmProj, spmTarget) = try pbxProject.getReferencedSPMTarget(named: productName, xcodeprojURL: project.xcodeprojURL, spmCache: project.spmCache) else {
										throw Err.internalError("SPM target \(productName) not found in referenced files.")
									}
									return .spmTarget(spmTarget, project: spmProj)
								}
							} else {
								throw Err.internalError("target and productRef are nil: AFAIK this is an invalid pbxproj.")
							}
						}
				}
				
			case let .spmTarget(target, _):
				return target.dependencies.map{ .spmTarget($0, project: nil) }
		}
	}
	
	public func getImplicitDirectDependencies() throws -> [Target] {
		switch self {
			case let .xcodeTarget(targetID, project):
				return try project.managedObjectContext.performAndWait{
					let xcodeTarget = try unsafeXcodeTargetFromID(targetID, context: project.managedObjectContext)
					let pbxProject = try xcodeTarget.getProject()
					/* Implicit dependencies discovery algo: <https://stackoverflow.com/a/45179347> or <https://stackoverflow.com/a/59218952>. */
					Conf.logger?.warning("Only package product implicit dependencies retrieval is implemented. Discovery of implicit Xcode target dependencies has not been implemented.")
					/* We consider the packageProductDependencies to be implicit.
					 * They are indeed not defined in the “dependencies” of a target (but they are defined directly in packageProductDependencies by Xcode). */
					let packageProductDeps = try (xcodeTarget as? PBXNativeTarget)?
						.packageProductDependencies?
						.compactMap{ packageProductDep -> Target? in
							if let _ = packageProductDep.package {
								Conf.logger?.warning("Skipped unsupported external SPM dependency.")
								return nil
							} else {
								let productName = try packageProductDep.getProductName()
								guard let (spmProj, spmTarget) = try pbxProject.getReferencedSPMTarget(named: productName, xcodeprojURL: project.xcodeprojURL, spmCache: project.spmCache) else {
									throw Err.internalError("SPM target \(productName) not found in referenced files.")
								}
								return .spmTarget(spmTarget, project: spmProj)
							}
						}
					return packageProductDeps ?? []
				}
				
			case .spmTarget:
				/* SPM target dependencies are all explicit (AFAIK). */
				return []
		}
	}
	
	public func getRecursiveDependencies() throws -> Set<Target> {
		return try getRecursiveDependencies([])
	}
	
	private func getRecursiveDependencies(_ treated: Set<Target>) throws -> Set<Target> {
		guard !treated.contains(self) else {return []}
		
		let deps = try getDirectDependencies()
		return try deps.union(deps.flatMap{ try $0.getRecursiveDependencies(treated.union([self])) })
	}
	
	private func unsafeXcodeTargetFromID(_ targetID: NSManagedObjectID, context: NSManagedObjectContext) throws -> PBXTarget {
		guard let target = try context.existingObject(with: targetID) as? PBXTarget else {
			throw Err.internalError("Invalid target ID whose linked object is not kind of PBXTarget.")
		}
		return target
	}
	
}
