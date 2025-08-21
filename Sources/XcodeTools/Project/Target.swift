import CoreData
import Foundation

import GlobalConfModule
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
					return try onContext_xcodeTargetFromID(targetID, context: project.managedObjectContext).getName()
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
					return try onContext_xcodeTargetFromID(targetID, context: project.managedObjectContext)
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
					return try onContext_xcodeTargetFromID(targetID, context: project.managedObjectContext)
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
	
	public func getDirectDependencies() async throws -> Set<Target> {
		return try await Set(getExplicitDirectDependencies() + getImplicitDirectDependencies())
	}
	
	public func getExplicitDirectDependencies() async throws -> [Target] {
		switch self {
			case let .xcodeTarget(targetID, project):
				let resultClosures: [() async throws -> Target] = try await project.managedObjectContext.perform{
					let xcodeTarget = try onContext_xcodeTargetFromID(targetID, context: project.managedObjectContext)
					let pbxProject = try xcodeTarget.getProject()
					assert(pbxProject === project.pbxproj.rootObject)
					
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
								return { .xcodeTarget(targetID: target.objectID, project: project) }
								
							} else if let productRef = dependency.productRef {
								if let package = productRef.package {
									Conf.logger?.warning("Skipped unsupported external SPM dependency.", metadata: ["dependency-url": (try? package.getRepositoryURL()).flatMap{ "\($0)" } ?? "<unknown>"])
									return nil
								} else {
									let productName = try productRef.getProductName()
									return {
										guard let (spmProj, spmTarget) = try await project.getReferencedSPMTarget(named: productName) else {
											throw Err.internalError("SPM target \(productName) not found in referenced files.")
										}
										return .spmTarget(spmTarget, project: spmProj)
									}
								}
								
							} else {
								throw Err.internalError("target and productRef are nil: AFAIK this is an invalid pbxproj.")
							}
						}
				}
				var res = [Target]()
				for closure in resultClosures {
					res.append(try await closure())
				}
				return res
				
			case let .spmTarget(target, _):
				return target.dependencies.map{ .spmTarget($0, project: nil) }
		}
	}
	
	public func getImplicitDirectDependencies() async throws -> [Target] {
		switch self {
			case let .xcodeTarget(targetID, project):
				let resultClosures: [() async throws -> Target] = try await project.managedObjectContext.perform{
					let xcodeTarget = try onContext_xcodeTargetFromID(targetID, context: project.managedObjectContext)
					let pbxProject = try xcodeTarget.getProject()
					assert(pbxProject === project.pbxproj.rootObject)
					
					/* Implicit dependencies discovery algo: <https://stackoverflow.com/a/45179347> or <https://stackoverflow.com/a/59218952>. */
					Conf.logger?.warning("Only package product implicit dependencies retrieval is implemented. Discovery of implicit Xcode target dependencies has not been implemented.")
					
					/* We consider the packageProductDependencies to be implicit.
					 * They are indeed not defined in the “dependencies” of a target (but they are defined directly in packageProductDependencies by Xcode). */
					let packageProductDepClosures = try (xcodeTarget as? PBXNativeTarget)?
						.packageProductDependencies?
						.compactMap{ packageProductDep -> (() async throws -> Target)? in
							if let package = packageProductDep.package {
								Conf.logger?.warning("Skipped unsupported external SPM dependency.", metadata: ["dependency-url": (try? package.getRepositoryURL()).flatMap{ "\($0)" } ?? "<unknown>"])
								return nil
							} else {
								let productName = try packageProductDep.getProductName()
								return {
									guard let (spmProj, spmTarget) = try await project.getReferencedSPMTarget(named: productName) else {
										throw Err.internalError("SPM target \(productName) not found in referenced files.")
									}
									return .spmTarget(spmTarget, project: spmProj)
								}
							}
						}
					
					return packageProductDepClosures ?? []
				}
				var res = [Target]()
				for closure in resultClosures {
					res.append(try await closure())
				}
				return res
				
			case .spmTarget:
				/* SPM target dependencies are all explicit (AFAIK). */
				return []
		}
	}
	
	public func getRecursiveDependencies() async throws -> Set<Target> {
		var treated = Set<Target>()
		return try await getRecursiveDependencies(&treated)
	}
	
	private func getRecursiveDependencies(_ treated: inout Set<Target>) async throws -> Set<Target> {
		guard !treated.contains(self) else {return []}
		treated.insert(self)
		
		let deps = try await getDirectDependencies()
		
		var subDeps = Set<Target>()
		for dep in deps {
			subDeps.formUnion(try await dep.getRecursiveDependencies(&treated))
		}
		return deps.union(subDeps)
	}
	
	private func onContext_xcodeTargetFromID(_ targetID: NSManagedObjectID, context: NSManagedObjectContext) throws -> PBXTarget {
		guard let target = try context.existingObject(with: targetID) as? PBXTarget else {
			throw Err.internalError("Invalid target ID whose linked object is not kind of PBXTarget.")
		}
		return target
	}
	
}
