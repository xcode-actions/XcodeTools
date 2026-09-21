//
/*
 * PBXTarget+CoreDataProperties.swift
 * 
 *
 * Created by François Lamboley on 2026/09/21.
 * 
 */
//  This file was automatically generated and should not be edited.
//

public import Foundation
public import CoreData


public typealias PBXTargetCoreDataPropertiesSet = NSSet

extension PBXTarget {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PBXTarget> {
        return NSFetchRequest<PBXTarget>(entityName: "PBXTarget")
    }

    @NSManaged nonisolated public var name: String?
    @NSManaged nonisolated public var productName: String?
    @NSManaged nonisolated public var buildConfigurationList: XCConfigurationList?
    @NSManaged nonisolated public var buildPhases_cd: NSOrderedSet?
    @NSManaged nonisolated public var dependencies_cd: NSOrderedSet?
    @NSManaged nonisolated public var i_project: PBXProject?
    @NSManaged nonisolated public var i_targetDependencies: NSSet?

}

// MARK: Generated accessors for buildPhases_cd
extension PBXTarget {

    @objc(insertObject:inBuildPhases_cdAtIndex:)
    @NSManaged nonisolated public func insertIntoBuildPhases_cd(_ value: PBXBuildPhase, at idx: Int)

    @objc(removeObjectFromBuildPhases_cdAtIndex:)
    @NSManaged nonisolated public func removeFromBuildPhases_cd(at idx: Int)

    @objc(insertBuildPhases_cd:atIndexes:)
    @NSManaged nonisolated public func insertIntoBuildPhases_cd(_ values: [PBXBuildPhase], at indexes: NSIndexSet)

    @objc(removeBuildPhases_cdAtIndexes:)
    @NSManaged nonisolated public func removeFromBuildPhases_cd(at indexes: NSIndexSet)

    @objc(replaceObjectInBuildPhases_cdAtIndex:withObject:)
    @NSManaged nonisolated public func replaceBuildPhases_cd(at idx: Int, with value: PBXBuildPhase)

    @objc(replaceBuildPhases_cdAtIndexes:withBuildPhases_cd:)
    @NSManaged nonisolated public func replaceBuildPhases_cd(at indexes: NSIndexSet, with values: [PBXBuildPhase])

    @objc(addBuildPhases_cdObject:)
    @NSManaged nonisolated public func addToBuildPhases_cd(_ value: PBXBuildPhase)

    @objc(removeBuildPhases_cdObject:)
    @NSManaged nonisolated public func removeFromBuildPhases_cd(_ value: PBXBuildPhase)

    @objc(addBuildPhases_cd:)
    @NSManaged nonisolated public func addToBuildPhases_cd(_ values: NSOrderedSet)

    @objc(removeBuildPhases_cd:)
    @NSManaged nonisolated public func removeFromBuildPhases_cd(_ values: NSOrderedSet)

}

// MARK: Generated accessors for dependencies_cd
extension PBXTarget {

    @objc(insertObject:inDependencies_cdAtIndex:)
    @NSManaged nonisolated public func insertIntoDependencies_cd(_ value: PBXTargetDependency, at idx: Int)

    @objc(removeObjectFromDependencies_cdAtIndex:)
    @NSManaged nonisolated public func removeFromDependencies_cd(at idx: Int)

    @objc(insertDependencies_cd:atIndexes:)
    @NSManaged nonisolated public func insertIntoDependencies_cd(_ values: [PBXTargetDependency], at indexes: NSIndexSet)

    @objc(removeDependencies_cdAtIndexes:)
    @NSManaged nonisolated public func removeFromDependencies_cd(at indexes: NSIndexSet)

    @objc(replaceObjectInDependencies_cdAtIndex:withObject:)
    @NSManaged nonisolated public func replaceDependencies_cd(at idx: Int, with value: PBXTargetDependency)

    @objc(replaceDependencies_cdAtIndexes:withDependencies_cd:)
    @NSManaged nonisolated public func replaceDependencies_cd(at indexes: NSIndexSet, with values: [PBXTargetDependency])

    @objc(addDependencies_cdObject:)
    @NSManaged nonisolated public func addToDependencies_cd(_ value: PBXTargetDependency)

    @objc(removeDependencies_cdObject:)
    @NSManaged nonisolated public func removeFromDependencies_cd(_ value: PBXTargetDependency)

    @objc(addDependencies_cd:)
    @NSManaged nonisolated public func addToDependencies_cd(_ values: NSOrderedSet)

    @objc(removeDependencies_cd:)
    @NSManaged nonisolated public func removeFromDependencies_cd(_ values: NSOrderedSet)

}

// MARK: Generated accessors for i_targetDependencies
extension PBXTarget {

    @objc(addI_targetDependenciesObject:)
    @NSManaged nonisolated public func addToI_targetDependencies(_ value: PBXTargetDependency)

    @objc(removeI_targetDependenciesObject:)
    @NSManaged nonisolated public func removeFromI_targetDependencies(_ value: PBXTargetDependency)

    @objc(addI_targetDependencies:)
    @NSManaged nonisolated public func addToI_targetDependencies(_ values: NSSet)

    @objc(removeI_targetDependencies:)
    @NSManaged nonisolated public func removeFromI_targetDependencies(_ values: NSSet)

}
