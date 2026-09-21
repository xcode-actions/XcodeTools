//
/*
 * PBXProject+CoreDataProperties.swift
 * 
 *
 * Created by François Lamboley on 2026/09/21.
 * 
 */
//  This file was automatically generated and should not be edited.
//

public import Foundation
public import CoreData


public typealias PBXProjectCoreDataPropertiesSet = NSSet

extension PBXProject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PBXProject> {
        return NSFetchRequest<PBXProject>(entityName: "PBXProject")
    }

    @NSManaged nonisolated public var attributes: [String: Any]?
    @NSManaged nonisolated public var compatibilityVersion: String?
    @NSManaged nonisolated public var developmentRegion: String?
    @NSManaged nonisolated public var hasScannedForEncodings: Bool
    @NSManaged nonisolated public var knownRegions: [String]?
    @NSManaged nonisolated public var packageReferences_isSet: Bool
    @NSManaged nonisolated public var projectDirPath: String?
    @NSManaged nonisolated public var projectReferences_isSet: Bool
    @NSManaged nonisolated public var projectRoot: String?
    @NSManaged nonisolated public var buildConfigurationList: XCConfigurationList?
    @NSManaged nonisolated public var mainGroup: PBXGroup?
    @NSManaged nonisolated public var packageReferences_cd: NSOrderedSet?
    @NSManaged nonisolated public var productRefGroup: PBXGroup?
    @NSManaged nonisolated public var projectReferences_cd: NSOrderedSet?
    @NSManaged nonisolated public var targets_cd: NSOrderedSet?

}

// MARK: Generated accessors for packageReferences_cd
extension PBXProject {

    @objc(insertObject:inPackageReferences_cdAtIndex:)
    @NSManaged nonisolated public func insertIntoPackageReferences_cd(_ value: XCRemoteSwiftPackageReference, at idx: Int)

    @objc(removeObjectFromPackageReferences_cdAtIndex:)
    @NSManaged nonisolated public func removeFromPackageReferences_cd(at idx: Int)

    @objc(insertPackageReferences_cd:atIndexes:)
    @NSManaged nonisolated public func insertIntoPackageReferences_cd(_ values: [XCRemoteSwiftPackageReference], at indexes: NSIndexSet)

    @objc(removePackageReferences_cdAtIndexes:)
    @NSManaged nonisolated public func removeFromPackageReferences_cd(at indexes: NSIndexSet)

    @objc(replaceObjectInPackageReferences_cdAtIndex:withObject:)
    @NSManaged nonisolated public func replacePackageReferences_cd(at idx: Int, with value: XCRemoteSwiftPackageReference)

    @objc(replacePackageReferences_cdAtIndexes:withPackageReferences_cd:)
    @NSManaged nonisolated public func replacePackageReferences_cd(at indexes: NSIndexSet, with values: [XCRemoteSwiftPackageReference])

    @objc(addPackageReferences_cdObject:)
    @NSManaged nonisolated public func addToPackageReferences_cd(_ value: XCRemoteSwiftPackageReference)

    @objc(removePackageReferences_cdObject:)
    @NSManaged nonisolated public func removeFromPackageReferences_cd(_ value: XCRemoteSwiftPackageReference)

    @objc(addPackageReferences_cd:)
    @NSManaged nonisolated public func addToPackageReferences_cd(_ values: NSOrderedSet)

    @objc(removePackageReferences_cd:)
    @NSManaged nonisolated public func removeFromPackageReferences_cd(_ values: NSOrderedSet)

}

// MARK: Generated accessors for projectReferences_cd
extension PBXProject {

    @objc(insertObject:inProjectReferences_cdAtIndex:)
    @NSManaged nonisolated public func insertIntoProjectReferences_cd(_ value: ProjectReference, at idx: Int)

    @objc(removeObjectFromProjectReferences_cdAtIndex:)
    @NSManaged nonisolated public func removeFromProjectReferences_cd(at idx: Int)

    @objc(insertProjectReferences_cd:atIndexes:)
    @NSManaged nonisolated public func insertIntoProjectReferences_cd(_ values: [ProjectReference], at indexes: NSIndexSet)

    @objc(removeProjectReferences_cdAtIndexes:)
    @NSManaged nonisolated public func removeFromProjectReferences_cd(at indexes: NSIndexSet)

    @objc(replaceObjectInProjectReferences_cdAtIndex:withObject:)
    @NSManaged nonisolated public func replaceProjectReferences_cd(at idx: Int, with value: ProjectReference)

    @objc(replaceProjectReferences_cdAtIndexes:withProjectReferences_cd:)
    @NSManaged nonisolated public func replaceProjectReferences_cd(at indexes: NSIndexSet, with values: [ProjectReference])

    @objc(addProjectReferences_cdObject:)
    @NSManaged nonisolated public func addToProjectReferences_cd(_ value: ProjectReference)

    @objc(removeProjectReferences_cdObject:)
    @NSManaged nonisolated public func removeFromProjectReferences_cd(_ value: ProjectReference)

    @objc(addProjectReferences_cd:)
    @NSManaged nonisolated public func addToProjectReferences_cd(_ values: NSOrderedSet)

    @objc(removeProjectReferences_cd:)
    @NSManaged nonisolated public func removeFromProjectReferences_cd(_ values: NSOrderedSet)

}

// MARK: Generated accessors for targets_cd
extension PBXProject {

    @objc(insertObject:inTargets_cdAtIndex:)
    @NSManaged nonisolated public func insertIntoTargets_cd(_ value: PBXTarget, at idx: Int)

    @objc(removeObjectFromTargets_cdAtIndex:)
    @NSManaged nonisolated public func removeFromTargets_cd(at idx: Int)

    @objc(insertTargets_cd:atIndexes:)
    @NSManaged nonisolated public func insertIntoTargets_cd(_ values: [PBXTarget], at indexes: NSIndexSet)

    @objc(removeTargets_cdAtIndexes:)
    @NSManaged nonisolated public func removeFromTargets_cd(at indexes: NSIndexSet)

    @objc(replaceObjectInTargets_cdAtIndex:withObject:)
    @NSManaged nonisolated public func replaceTargets_cd(at idx: Int, with value: PBXTarget)

    @objc(replaceTargets_cdAtIndexes:withTargets_cd:)
    @NSManaged nonisolated public func replaceTargets_cd(at indexes: NSIndexSet, with values: [PBXTarget])

    @objc(addTargets_cdObject:)
    @NSManaged nonisolated public func addToTargets_cd(_ value: PBXTarget)

    @objc(removeTargets_cdObject:)
    @NSManaged nonisolated public func removeFromTargets_cd(_ value: PBXTarget)

    @objc(addTargets_cd:)
    @NSManaged nonisolated public func addToTargets_cd(_ values: NSOrderedSet)

    @objc(removeTargets_cd:)
    @NSManaged nonisolated public func removeFromTargets_cd(_ values: NSOrderedSet)

}
