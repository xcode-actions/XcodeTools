//
/*
 * XCVersionGroup+CoreDataProperties.swift
 * 
 *
 * Created by François Lamboley on 2026/09/21.
 * 
 */
//  This file was automatically generated and should not be edited.
//

public import Foundation
public import CoreData


public typealias XCVersionGroupCoreDataPropertiesSet = NSSet

extension XCVersionGroup {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<XCVersionGroup> {
        return NSFetchRequest<XCVersionGroup>(entityName: "XCVersionGroup")
    }

    @NSManaged nonisolated public var versionGroupType: String?
    @NSManaged nonisolated public var children_cd: NSOrderedSet?
    @NSManaged nonisolated public var currentVersion: PBXFileReference?

}

// MARK: Generated accessors for children_cd
extension XCVersionGroup {

    @objc(insertObject:inChildren_cdAtIndex:)
    @NSManaged nonisolated public func insertIntoChildren_cd(_ value: PBXFileReference, at idx: Int)

    @objc(removeObjectFromChildren_cdAtIndex:)
    @NSManaged nonisolated public func removeFromChildren_cd(at idx: Int)

    @objc(insertChildren_cd:atIndexes:)
    @NSManaged nonisolated public func insertIntoChildren_cd(_ values: [PBXFileReference], at indexes: NSIndexSet)

    @objc(removeChildren_cdAtIndexes:)
    @NSManaged nonisolated public func removeFromChildren_cd(at indexes: NSIndexSet)

    @objc(replaceObjectInChildren_cdAtIndex:withObject:)
    @NSManaged nonisolated public func replaceChildren_cd(at idx: Int, with value: PBXFileReference)

    @objc(replaceChildren_cdAtIndexes:withChildren_cd:)
    @NSManaged nonisolated public func replaceChildren_cd(at indexes: NSIndexSet, with values: [PBXFileReference])

    @objc(addChildren_cdObject:)
    @NSManaged nonisolated public func addToChildren_cd(_ value: PBXFileReference)

    @objc(removeChildren_cdObject:)
    @NSManaged nonisolated public func removeFromChildren_cd(_ value: PBXFileReference)

    @objc(addChildren_cd:)
    @NSManaged nonisolated public func addToChildren_cd(_ values: NSOrderedSet)

    @objc(removeChildren_cd:)
    @NSManaged nonisolated public func removeFromChildren_cd(_ values: NSOrderedSet)

}
