//
/*
 * PBXFileElement+CoreDataProperties.swift
 * 
 *
 * Created by François Lamboley on 2026/09/21.
 * 
 */
//  This file was automatically generated and should not be edited.
//

public import Foundation
public import CoreData


public typealias PBXFileElementCoreDataPropertiesSet = NSSet

extension PBXFileElement {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PBXFileElement> {
        return NSFetchRequest<PBXFileElement>(entityName: "PBXFileElement")
    }

    @NSManaged nonisolated public var indentWidth: NSNumber?
    @NSManaged nonisolated public var rawName: String?
    @NSManaged nonisolated public var rawPath: String?
    @NSManaged nonisolated public var rawSourceTree: String?
    @NSManaged nonisolated public var tabWidth: NSNumber?
    @NSManaged nonisolated public var usesTabs: NSNumber?
    @NSManaged nonisolated public var wrapsLines: NSNumber?
    @NSManaged nonisolated public var i_buildFiles: NSSet?
    @NSManaged nonisolated public var i_group: PBXGroup?
    @NSManaged nonisolated public var i_projectReference1: NSSet?
    @NSManaged nonisolated public var i_projectReference2: NSSet?

}

// MARK: Generated accessors for i_buildFiles
extension PBXFileElement {

    @objc(addI_buildFilesObject:)
    @NSManaged nonisolated public func addToI_buildFiles(_ value: PBXBuildFile)

    @objc(removeI_buildFilesObject:)
    @NSManaged nonisolated public func removeFromI_buildFiles(_ value: PBXBuildFile)

    @objc(addI_buildFiles:)
    @NSManaged nonisolated public func addToI_buildFiles(_ values: NSSet)

    @objc(removeI_buildFiles:)
    @NSManaged nonisolated public func removeFromI_buildFiles(_ values: NSSet)

}

// MARK: Generated accessors for i_projectReference1
extension PBXFileElement {

    @objc(addI_projectReference1Object:)
    @NSManaged nonisolated public func addToI_projectReference1(_ value: ProjectReference)

    @objc(removeI_projectReference1Object:)
    @NSManaged nonisolated public func removeFromI_projectReference1(_ value: ProjectReference)

    @objc(addI_projectReference1:)
    @NSManaged nonisolated public func addToI_projectReference1(_ values: NSSet)

    @objc(removeI_projectReference1:)
    @NSManaged nonisolated public func removeFromI_projectReference1(_ values: NSSet)

}

// MARK: Generated accessors for i_projectReference2
extension PBXFileElement {

    @objc(addI_projectReference2Object:)
    @NSManaged nonisolated public func addToI_projectReference2(_ value: ProjectReference)

    @objc(removeI_projectReference2Object:)
    @NSManaged nonisolated public func removeFromI_projectReference2(_ value: ProjectReference)

    @objc(addI_projectReference2:)
    @NSManaged nonisolated public func addToI_projectReference2(_ values: NSSet)

    @objc(removeI_projectReference2:)
    @NSManaged nonisolated public func removeFromI_projectReference2(_ values: NSSet)

}
