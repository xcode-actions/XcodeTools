//
//  XCVersionGroup+CoreDataProperties.swift
//  
//
//  Created by François Lamboley on 2021/6/1.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension XCVersionGroup {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<XCVersionGroup> {
        return NSFetchRequest<XCVersionGroup>(entityName: "XCVersionGroup")
    }

    @NSManaged public var versionGroupType: String?
    @NSManaged public var children_cd: NSOrderedSet?
    @NSManaged public var currentVersion: PBXFileReference?

}

// MARK: Generated accessors for children_cd
extension XCVersionGroup {

    @objc(insertObject:inChildren_cdAtIndex:)
    @NSManaged public func insertIntoChildren_cd(_ value: PBXFileReference, at idx: Int)

    @objc(removeObjectFromChildren_cdAtIndex:)
    @NSManaged public func removeFromChildren_cd(at idx: Int)

    @objc(insertChildren_cd:atIndexes:)
    @NSManaged public func insertIntoChildren_cd(_ values: [PBXFileReference], at indexes: NSIndexSet)

    @objc(removeChildren_cdAtIndexes:)
    @NSManaged public func removeFromChildren_cd(at indexes: NSIndexSet)

    @objc(replaceObjectInChildren_cdAtIndex:withObject:)
    @NSManaged public func replaceChildren_cd(at idx: Int, with value: PBXFileReference)

    @objc(replaceChildren_cdAtIndexes:withChildren_cd:)
    @NSManaged public func replaceChildren_cd(at indexes: NSIndexSet, with values: [PBXFileReference])

    @objc(addChildren_cdObject:)
    @NSManaged public func addToChildren_cd(_ value: PBXFileReference)

    @objc(removeChildren_cdObject:)
    @NSManaged public func removeFromChildren_cd(_ value: PBXFileReference)

    @objc(addChildren_cd:)
    @NSManaged public func addToChildren_cd(_ values: NSOrderedSet)

    @objc(removeChildren_cd:)
    @NSManaged public func removeFromChildren_cd(_ values: NSOrderedSet)

}
