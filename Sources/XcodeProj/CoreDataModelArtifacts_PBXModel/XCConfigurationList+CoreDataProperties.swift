//
/*
 * XCConfigurationList+CoreDataProperties.swift
 * 
 *
 * Created by François Lamboley on 2026/09/21.
 * 
 */
//  This file was automatically generated and should not be edited.
//

public import Foundation
public import CoreData


public typealias XCConfigurationListCoreDataPropertiesSet = NSSet

extension XCConfigurationList {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<XCConfigurationList> {
        return NSFetchRequest<XCConfigurationList>(entityName: "XCConfigurationList")
    }

    @NSManaged nonisolated public var defaultConfigurationIsVisible: Bool
    @NSManaged nonisolated public var defaultConfigurationName: String?
    @NSManaged nonisolated public var buildConfigurations_cd: NSOrderedSet?
    @NSManaged nonisolated public var i_project: PBXProject?
    @NSManaged nonisolated public var i_target: PBXTarget?

}

// MARK: Generated accessors for buildConfigurations_cd
extension XCConfigurationList {

    @objc(insertObject:inBuildConfigurations_cdAtIndex:)
    @NSManaged nonisolated public func insertIntoBuildConfigurations_cd(_ value: XCBuildConfiguration, at idx: Int)

    @objc(removeObjectFromBuildConfigurations_cdAtIndex:)
    @NSManaged nonisolated public func removeFromBuildConfigurations_cd(at idx: Int)

    @objc(insertBuildConfigurations_cd:atIndexes:)
    @NSManaged nonisolated public func insertIntoBuildConfigurations_cd(_ values: [XCBuildConfiguration], at indexes: NSIndexSet)

    @objc(removeBuildConfigurations_cdAtIndexes:)
    @NSManaged nonisolated public func removeFromBuildConfigurations_cd(at indexes: NSIndexSet)

    @objc(replaceObjectInBuildConfigurations_cdAtIndex:withObject:)
    @NSManaged nonisolated public func replaceBuildConfigurations_cd(at idx: Int, with value: XCBuildConfiguration)

    @objc(replaceBuildConfigurations_cdAtIndexes:withBuildConfigurations_cd:)
    @NSManaged nonisolated public func replaceBuildConfigurations_cd(at indexes: NSIndexSet, with values: [XCBuildConfiguration])

    @objc(addBuildConfigurations_cdObject:)
    @NSManaged nonisolated public func addToBuildConfigurations_cd(_ value: XCBuildConfiguration)

    @objc(removeBuildConfigurations_cdObject:)
    @NSManaged nonisolated public func removeFromBuildConfigurations_cd(_ value: XCBuildConfiguration)

    @objc(addBuildConfigurations_cd:)
    @NSManaged nonisolated public func addToBuildConfigurations_cd(_ values: NSOrderedSet)

    @objc(removeBuildConfigurations_cd:)
    @NSManaged nonisolated public func removeFromBuildConfigurations_cd(_ values: NSOrderedSet)

}
