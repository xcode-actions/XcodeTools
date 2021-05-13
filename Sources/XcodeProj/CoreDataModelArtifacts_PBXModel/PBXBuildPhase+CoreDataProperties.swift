//
//  PBXBuildPhase+CoreDataProperties.swift
//  
//
//  Created by François Lamboley on 13/05/2021.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension PBXBuildPhase {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PBXBuildPhase> {
        return NSFetchRequest<PBXBuildPhase>(entityName: "PBXBuildPhase")
    }

    @NSManaged public var buildActionMask: NSNumber?
    @NSManaged public var name: String?
    @NSManaged public var runOnlyForDeploymentPostprocessing: NSNumber?
    @NSManaged public var files_cd: NSOrderedSet?
    @NSManaged public var targets_: NSSet?

}

// MARK: Generated accessors for files_cd
extension PBXBuildPhase {

    @objc(insertObject:inFiles_cdAtIndex:)
    @NSManaged public func insertIntoFiles_cd(_ value: PBXBuildFile, at idx: Int)

    @objc(removeObjectFromFiles_cdAtIndex:)
    @NSManaged public func removeFromFiles_cd(at idx: Int)

    @objc(insertFiles_cd:atIndexes:)
    @NSManaged public func insertIntoFiles_cd(_ values: [PBXBuildFile], at indexes: NSIndexSet)

    @objc(removeFiles_cdAtIndexes:)
    @NSManaged public func removeFromFiles_cd(at indexes: NSIndexSet)

    @objc(replaceObjectInFiles_cdAtIndex:withObject:)
    @NSManaged public func replaceFiles_cd(at idx: Int, with value: PBXBuildFile)

    @objc(replaceFiles_cdAtIndexes:withFiles_cd:)
    @NSManaged public func replaceFiles_cd(at indexes: NSIndexSet, with values: [PBXBuildFile])

    @objc(addFiles_cdObject:)
    @NSManaged public func addToFiles_cd(_ value: PBXBuildFile)

    @objc(removeFiles_cdObject:)
    @NSManaged public func removeFromFiles_cd(_ value: PBXBuildFile)

    @objc(addFiles_cd:)
    @NSManaged public func addToFiles_cd(_ values: NSOrderedSet)

    @objc(removeFiles_cd:)
    @NSManaged public func removeFromFiles_cd(_ values: NSOrderedSet)

}

// MARK: Generated accessors for targets_
extension PBXBuildPhase {

    @objc(addTargets_Object:)
    @NSManaged public func addToTargets_(_ value: PBXTarget)

    @objc(removeTargets_Object:)
    @NSManaged public func removeFromTargets_(_ value: PBXTarget)

    @objc(addTargets_:)
    @NSManaged public func addToTargets_(_ values: NSSet)

    @objc(removeTargets_:)
    @NSManaged public func removeFromTargets_(_ values: NSSet)

}
