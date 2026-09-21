//
/*
 * PBXGroup+CoreDataProperties.swift
 * 
 *
 * Created by François Lamboley on 2026/09/21.
 * 
 */
//  This file was automatically generated and should not be edited.
//

public import Foundation
public import CoreData


public typealias PBXGroupCoreDataPropertiesSet = NSSet

extension PBXGroup {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PBXGroup> {
        return NSFetchRequest<PBXGroup>(entityName: "PBXGroup")
    }

    @NSManaged nonisolated public var children_isSet: Bool
    @NSManaged nonisolated public var children_cd: NSOrderedSet?
    @NSManaged nonisolated public var i_projectForMainGroup: PBXProject?
    @NSManaged nonisolated public var i_projectForProductRef: PBXProject?

}

// MARK: Generated accessors for children_cd
extension PBXGroup {

    @objc(insertObject:inChildren_cdAtIndex:)
    @NSManaged nonisolated public func insertIntoChildren_cd(_ value: PBXFileElement, at idx: Int)

    @objc(removeObjectFromChildren_cdAtIndex:)
    @NSManaged nonisolated public func removeFromChildren_cd(at idx: Int)

    @objc(insertChildren_cd:atIndexes:)
    @NSManaged nonisolated public func insertIntoChildren_cd(_ values: [PBXFileElement], at indexes: NSIndexSet)

    @objc(removeChildren_cdAtIndexes:)
    @NSManaged nonisolated public func removeFromChildren_cd(at indexes: NSIndexSet)

    @objc(replaceObjectInChildren_cdAtIndex:withObject:)
    @NSManaged nonisolated public func replaceChildren_cd(at idx: Int, with value: PBXFileElement)

    @objc(replaceChildren_cdAtIndexes:withChildren_cd:)
    @NSManaged nonisolated public func replaceChildren_cd(at indexes: NSIndexSet, with values: [PBXFileElement])

    @objc(addChildren_cdObject:)
    @NSManaged nonisolated public func addToChildren_cd(_ value: PBXFileElement)

    @objc(removeChildren_cdObject:)
    @NSManaged nonisolated public func removeFromChildren_cd(_ value: PBXFileElement)

    @objc(addChildren_cd:)
    @NSManaged nonisolated public func addToChildren_cd(_ values: NSOrderedSet)

    @objc(removeChildren_cd:)
    @NSManaged nonisolated public func removeFromChildren_cd(_ values: NSOrderedSet)

}
