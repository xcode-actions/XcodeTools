//
//  PBXProject+CoreDataProperties.swift
//  
//
//  Created by François Lamboley on 2021/5/30.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension PBXProject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PBXProject> {
        return NSFetchRequest<PBXProject>(entityName: "PBXProject")
    }

    @NSManaged public var attributes: [String: Any]?
    @NSManaged public var compatibilityVersion: String?
    @NSManaged public var developmentRegion: String?
    @NSManaged public var hasScannedForEncodings: Bool
    @NSManaged public var knownRegions: [String]?
    @NSManaged public var packageReferences_isSet: Bool
    @NSManaged public var projectDirPath: String?
    @NSManaged public var projectReferences_isSet: Bool
    @NSManaged public var projectRoot: String?
    @NSManaged public var buildConfigurationList: XCConfigurationList?
    @NSManaged public var mainGroup: PBXGroup?
    @NSManaged public var packageReferences_cd: NSOrderedSet?
    @NSManaged public var productRefGroup: PBXGroup?
    @NSManaged public var projectReferences_cd: NSOrderedSet?
    @NSManaged public var targets_cd: NSOrderedSet?

}

// MARK: Generated accessors for packageReferences_cd
extension PBXProject {

    @objc(insertObject:inPackageReferences_cdAtIndex:)
    @NSManaged public func insertIntoPackageReferences_cd(_ value: XCRemoteSwiftPackageReference, at idx: Int)

    @objc(removeObjectFromPackageReferences_cdAtIndex:)
    @NSManaged public func removeFromPackageReferences_cd(at idx: Int)

    @objc(insertPackageReferences_cd:atIndexes:)
    @NSManaged public func insertIntoPackageReferences_cd(_ values: [XCRemoteSwiftPackageReference], at indexes: NSIndexSet)

    @objc(removePackageReferences_cdAtIndexes:)
    @NSManaged public func removeFromPackageReferences_cd(at indexes: NSIndexSet)

    @objc(replaceObjectInPackageReferences_cdAtIndex:withObject:)
    @NSManaged public func replacePackageReferences_cd(at idx: Int, with value: XCRemoteSwiftPackageReference)

    @objc(replacePackageReferences_cdAtIndexes:withPackageReferences_cd:)
    @NSManaged public func replacePackageReferences_cd(at indexes: NSIndexSet, with values: [XCRemoteSwiftPackageReference])

    @objc(addPackageReferences_cdObject:)
    @NSManaged public func addToPackageReferences_cd(_ value: XCRemoteSwiftPackageReference)

    @objc(removePackageReferences_cdObject:)
    @NSManaged public func removeFromPackageReferences_cd(_ value: XCRemoteSwiftPackageReference)

    @objc(addPackageReferences_cd:)
    @NSManaged public func addToPackageReferences_cd(_ values: NSOrderedSet)

    @objc(removePackageReferences_cd:)
    @NSManaged public func removeFromPackageReferences_cd(_ values: NSOrderedSet)

}

// MARK: Generated accessors for projectReferences_cd
extension PBXProject {

    @objc(insertObject:inProjectReferences_cdAtIndex:)
    @NSManaged public func insertIntoProjectReferences_cd(_ value: ProjectReference, at idx: Int)

    @objc(removeObjectFromProjectReferences_cdAtIndex:)
    @NSManaged public func removeFromProjectReferences_cd(at idx: Int)

    @objc(insertProjectReferences_cd:atIndexes:)
    @NSManaged public func insertIntoProjectReferences_cd(_ values: [ProjectReference], at indexes: NSIndexSet)

    @objc(removeProjectReferences_cdAtIndexes:)
    @NSManaged public func removeFromProjectReferences_cd(at indexes: NSIndexSet)

    @objc(replaceObjectInProjectReferences_cdAtIndex:withObject:)
    @NSManaged public func replaceProjectReferences_cd(at idx: Int, with value: ProjectReference)

    @objc(replaceProjectReferences_cdAtIndexes:withProjectReferences_cd:)
    @NSManaged public func replaceProjectReferences_cd(at indexes: NSIndexSet, with values: [ProjectReference])

    @objc(addProjectReferences_cdObject:)
    @NSManaged public func addToProjectReferences_cd(_ value: ProjectReference)

    @objc(removeProjectReferences_cdObject:)
    @NSManaged public func removeFromProjectReferences_cd(_ value: ProjectReference)

    @objc(addProjectReferences_cd:)
    @NSManaged public func addToProjectReferences_cd(_ values: NSOrderedSet)

    @objc(removeProjectReferences_cd:)
    @NSManaged public func removeFromProjectReferences_cd(_ values: NSOrderedSet)

}

// MARK: Generated accessors for targets_cd
extension PBXProject {

    @objc(insertObject:inTargets_cdAtIndex:)
    @NSManaged public func insertIntoTargets_cd(_ value: PBXTarget, at idx: Int)

    @objc(removeObjectFromTargets_cdAtIndex:)
    @NSManaged public func removeFromTargets_cd(at idx: Int)

    @objc(insertTargets_cd:atIndexes:)
    @NSManaged public func insertIntoTargets_cd(_ values: [PBXTarget], at indexes: NSIndexSet)

    @objc(removeTargets_cdAtIndexes:)
    @NSManaged public func removeFromTargets_cd(at indexes: NSIndexSet)

    @objc(replaceObjectInTargets_cdAtIndex:withObject:)
    @NSManaged public func replaceTargets_cd(at idx: Int, with value: PBXTarget)

    @objc(replaceTargets_cdAtIndexes:withTargets_cd:)
    @NSManaged public func replaceTargets_cd(at indexes: NSIndexSet, with values: [PBXTarget])

    @objc(addTargets_cdObject:)
    @NSManaged public func addToTargets_cd(_ value: PBXTarget)

    @objc(removeTargets_cdObject:)
    @NSManaged public func removeFromTargets_cd(_ value: PBXTarget)

    @objc(addTargets_cd:)
    @NSManaged public func addToTargets_cd(_ values: NSOrderedSet)

    @objc(removeTargets_cd:)
    @NSManaged public func removeFromTargets_cd(_ values: NSOrderedSet)

}
