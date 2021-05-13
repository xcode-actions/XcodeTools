//
//  PBXTarget+CoreDataProperties.swift
//  
//
//  Created by François Lamboley on 13/05/2021.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension PBXTarget {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PBXTarget> {
        return NSFetchRequest<PBXTarget>(entityName: "PBXTarget")
    }

    @NSManaged public var name: String?
    @NSManaged public var productName: String?
    @NSManaged public var buildConfigurationList: XCConfigurationList?
    @NSManaged public var buildPhases_cd: NSOrderedSet?
    @NSManaged public var dependencies_cd: NSOrderedSet?
    @NSManaged public var project_: PBXProject?
    @NSManaged public var targetDependencies_: NSSet?

}

// MARK: Generated accessors for buildPhases_cd
extension PBXTarget {

    @objc(insertObject:inBuildPhases_cdAtIndex:)
    @NSManaged public func insertIntoBuildPhases_cd(_ value: PBXBuildPhase, at idx: Int)

    @objc(removeObjectFromBuildPhases_cdAtIndex:)
    @NSManaged public func removeFromBuildPhases_cd(at idx: Int)

    @objc(insertBuildPhases_cd:atIndexes:)
    @NSManaged public func insertIntoBuildPhases_cd(_ values: [PBXBuildPhase], at indexes: NSIndexSet)

    @objc(removeBuildPhases_cdAtIndexes:)
    @NSManaged public func removeFromBuildPhases_cd(at indexes: NSIndexSet)

    @objc(replaceObjectInBuildPhases_cdAtIndex:withObject:)
    @NSManaged public func replaceBuildPhases_cd(at idx: Int, with value: PBXBuildPhase)

    @objc(replaceBuildPhases_cdAtIndexes:withBuildPhases_cd:)
    @NSManaged public func replaceBuildPhases_cd(at indexes: NSIndexSet, with values: [PBXBuildPhase])

    @objc(addBuildPhases_cdObject:)
    @NSManaged public func addToBuildPhases_cd(_ value: PBXBuildPhase)

    @objc(removeBuildPhases_cdObject:)
    @NSManaged public func removeFromBuildPhases_cd(_ value: PBXBuildPhase)

    @objc(addBuildPhases_cd:)
    @NSManaged public func addToBuildPhases_cd(_ values: NSOrderedSet)

    @objc(removeBuildPhases_cd:)
    @NSManaged public func removeFromBuildPhases_cd(_ values: NSOrderedSet)

}

// MARK: Generated accessors for dependencies_cd
extension PBXTarget {

    @objc(insertObject:inDependencies_cdAtIndex:)
    @NSManaged public func insertIntoDependencies_cd(_ value: PBXTargetDependency, at idx: Int)

    @objc(removeObjectFromDependencies_cdAtIndex:)
    @NSManaged public func removeFromDependencies_cd(at idx: Int)

    @objc(insertDependencies_cd:atIndexes:)
    @NSManaged public func insertIntoDependencies_cd(_ values: [PBXTargetDependency], at indexes: NSIndexSet)

    @objc(removeDependencies_cdAtIndexes:)
    @NSManaged public func removeFromDependencies_cd(at indexes: NSIndexSet)

    @objc(replaceObjectInDependencies_cdAtIndex:withObject:)
    @NSManaged public func replaceDependencies_cd(at idx: Int, with value: PBXTargetDependency)

    @objc(replaceDependencies_cdAtIndexes:withDependencies_cd:)
    @NSManaged public func replaceDependencies_cd(at indexes: NSIndexSet, with values: [PBXTargetDependency])

    @objc(addDependencies_cdObject:)
    @NSManaged public func addToDependencies_cd(_ value: PBXTargetDependency)

    @objc(removeDependencies_cdObject:)
    @NSManaged public func removeFromDependencies_cd(_ value: PBXTargetDependency)

    @objc(addDependencies_cd:)
    @NSManaged public func addToDependencies_cd(_ values: NSOrderedSet)

    @objc(removeDependencies_cd:)
    @NSManaged public func removeFromDependencies_cd(_ values: NSOrderedSet)

}

// MARK: Generated accessors for targetDependencies_
extension PBXTarget {

    @objc(addTargetDependencies_Object:)
    @NSManaged public func addToTargetDependencies_(_ value: PBXTargetDependency)

    @objc(removeTargetDependencies_Object:)
    @NSManaged public func removeFromTargetDependencies_(_ value: PBXTargetDependency)

    @objc(addTargetDependencies_:)
    @NSManaged public func addToTargetDependencies_(_ values: NSSet)

    @objc(removeTargetDependencies_:)
    @NSManaged public func removeFromTargetDependencies_(_ values: NSSet)

}
