//
/*
 * PBXBuildPhase+CoreDataProperties.swift
 * 
 *
 * Created by François Lamboley on 2026/09/21.
 * 
 */
//  This file was automatically generated and should not be edited.
//

public import Foundation
public import CoreData


public typealias PBXBuildPhaseCoreDataPropertiesSet = NSSet

extension PBXBuildPhase {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PBXBuildPhase> {
        return NSFetchRequest<PBXBuildPhase>(entityName: "PBXBuildPhase")
    }

    @NSManaged nonisolated public var buildActionMask: NSNumber?
    @NSManaged nonisolated public var name: String?
    @NSManaged nonisolated public var runOnlyForDeploymentPostprocessing: NSNumber?
    @NSManaged nonisolated public var files_cd: NSOrderedSet?
    @NSManaged nonisolated public var i_targets: NSSet?

}

// MARK: Generated accessors for files_cd
extension PBXBuildPhase {

    @objc(insertObject:inFiles_cdAtIndex:)
    @NSManaged nonisolated public func insertIntoFiles_cd(_ value: PBXBuildFile, at idx: Int)

    @objc(removeObjectFromFiles_cdAtIndex:)
    @NSManaged nonisolated public func removeFromFiles_cd(at idx: Int)

    @objc(insertFiles_cd:atIndexes:)
    @NSManaged nonisolated public func insertIntoFiles_cd(_ values: [PBXBuildFile], at indexes: NSIndexSet)

    @objc(removeFiles_cdAtIndexes:)
    @NSManaged nonisolated public func removeFromFiles_cd(at indexes: NSIndexSet)

    @objc(replaceObjectInFiles_cdAtIndex:withObject:)
    @NSManaged nonisolated public func replaceFiles_cd(at idx: Int, with value: PBXBuildFile)

    @objc(replaceFiles_cdAtIndexes:withFiles_cd:)
    @NSManaged nonisolated public func replaceFiles_cd(at indexes: NSIndexSet, with values: [PBXBuildFile])

    @objc(addFiles_cdObject:)
    @NSManaged nonisolated public func addToFiles_cd(_ value: PBXBuildFile)

    @objc(removeFiles_cdObject:)
    @NSManaged nonisolated public func removeFromFiles_cd(_ value: PBXBuildFile)

    @objc(addFiles_cd:)
    @NSManaged nonisolated public func addToFiles_cd(_ values: NSOrderedSet)

    @objc(removeFiles_cd:)
    @NSManaged nonisolated public func removeFromFiles_cd(_ values: NSOrderedSet)

}

// MARK: Generated accessors for i_targets
extension PBXBuildPhase {

    @objc(addI_targetsObject:)
    @NSManaged nonisolated public func addToI_targets(_ value: PBXTarget)

    @objc(removeI_targetsObject:)
    @NSManaged nonisolated public func removeFromI_targets(_ value: PBXTarget)

    @objc(addI_targets:)
    @NSManaged nonisolated public func addToI_targets(_ values: NSSet)

    @objc(removeI_targets:)
    @NSManaged nonisolated public func removeFromI_targets(_ values: NSSet)

}
