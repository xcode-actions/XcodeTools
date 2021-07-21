//
//  XCConfigurationList+CoreDataProperties.swift
//  
//
//  Created by François Lamboley on 2021/6/1.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension XCConfigurationList {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<XCConfigurationList> {
        return NSFetchRequest<XCConfigurationList>(entityName: "XCConfigurationList")
    }

    @NSManaged public var defaultConfigurationIsVisible: Bool
    @NSManaged public var defaultConfigurationName: String?
    @NSManaged public var buildConfigurations_cd: NSOrderedSet?
    @NSManaged public var project_: PBXProject?
    @NSManaged public var target_: PBXTarget?

}

// MARK: Generated accessors for buildConfigurations_cd
extension XCConfigurationList {

    @objc(insertObject:inBuildConfigurations_cdAtIndex:)
    @NSManaged public func insertIntoBuildConfigurations_cd(_ value: XCBuildConfiguration, at idx: Int)

    @objc(removeObjectFromBuildConfigurations_cdAtIndex:)
    @NSManaged public func removeFromBuildConfigurations_cd(at idx: Int)

    @objc(insertBuildConfigurations_cd:atIndexes:)
    @NSManaged public func insertIntoBuildConfigurations_cd(_ values: [XCBuildConfiguration], at indexes: NSIndexSet)

    @objc(removeBuildConfigurations_cdAtIndexes:)
    @NSManaged public func removeFromBuildConfigurations_cd(at indexes: NSIndexSet)

    @objc(replaceObjectInBuildConfigurations_cdAtIndex:withObject:)
    @NSManaged public func replaceBuildConfigurations_cd(at idx: Int, with value: XCBuildConfiguration)

    @objc(replaceBuildConfigurations_cdAtIndexes:withBuildConfigurations_cd:)
    @NSManaged public func replaceBuildConfigurations_cd(at indexes: NSIndexSet, with values: [XCBuildConfiguration])

    @objc(addBuildConfigurations_cdObject:)
    @NSManaged public func addToBuildConfigurations_cd(_ value: XCBuildConfiguration)

    @objc(removeBuildConfigurations_cdObject:)
    @NSManaged public func removeFromBuildConfigurations_cd(_ value: XCBuildConfiguration)

    @objc(addBuildConfigurations_cd:)
    @NSManaged public func addToBuildConfigurations_cd(_ values: NSOrderedSet)

    @objc(removeBuildConfigurations_cd:)
    @NSManaged public func removeFromBuildConfigurations_cd(_ values: NSOrderedSet)

}
