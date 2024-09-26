//
/*
 * PBXGroup+CoreDataProperties.swift
 * 
 *
 * Created by François Lamboley on 2025/08/21.
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

    @NSManaged public var children_isSet: Bool
    @NSManaged public var children_cd: NSOrderedSet?
    @NSManaged public var i_projectForMainGroup: PBXProject?
    @NSManaged public var i_projectForProductRef: PBXProject?

}

// MARK: Generated accessors for children_cd
extension PBXGroup {

    @objc(insertObject:inChildren_cdAtIndex:)
    @NSManaged public func insertIntoChildren_cd(_ value: PBXFileElement, at idx: Int)

    @objc(removeObjectFromChildren_cdAtIndex:)
    @NSManaged public func removeFromChildren_cd(at idx: Int)

    @objc(insertChildren_cd:atIndexes:)
    @NSManaged public func insertIntoChildren_cd(_ values: [PBXFileElement], at indexes: NSIndexSet)

    @objc(removeChildren_cdAtIndexes:)
    @NSManaged public func removeFromChildren_cd(at indexes: NSIndexSet)

    @objc(replaceObjectInChildren_cdAtIndex:withObject:)
    @NSManaged public func replaceChildren_cd(at idx: Int, with value: PBXFileElement)

    @objc(replaceChildren_cdAtIndexes:withChildren_cd:)
    @NSManaged public func replaceChildren_cd(at indexes: NSIndexSet, with values: [PBXFileElement])

    @objc(addChildren_cdObject:)
    @NSManaged public func addToChildren_cd(_ value: PBXFileElement)

    @objc(removeChildren_cdObject:)
    @NSManaged public func removeFromChildren_cd(_ value: PBXFileElement)

    @objc(addChildren_cd:)
    @NSManaged public func addToChildren_cd(_ values: NSOrderedSet)

    @objc(removeChildren_cd:)
    @NSManaged public func removeFromChildren_cd(_ values: NSOrderedSet)

}
