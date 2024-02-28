//
/*
 * PBXFileElement+CoreDataProperties.swift
 * 
 *
 * Created by François Lamboley on 2024/02/28.
 * 
 */
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension PBXFileElement {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PBXFileElement> {
        return NSFetchRequest<PBXFileElement>(entityName: "PBXFileElement")
    }

    @NSManaged public var indentWidth: NSNumber?
    @NSManaged public var rawName: String?
    @NSManaged public var rawPath: String?
    @NSManaged public var rawSourceTree: String?
    @NSManaged public var tabWidth: NSNumber?
    @NSManaged public var usesTabs: NSNumber?
    @NSManaged public var wrapsLines: NSNumber?
    @NSManaged public var i_buildFiles: NSSet?
    @NSManaged public var i_group: PBXGroup?
    @NSManaged public var i_projectReference1: NSSet?
    @NSManaged public var i_projectReference2: NSSet?

}

// MARK: Generated accessors for i_buildFiles
extension PBXFileElement {

    @objc(addI_buildFilesObject:)
    @NSManaged public func addToI_buildFiles(_ value: PBXBuildFile)

    @objc(removeI_buildFilesObject:)
    @NSManaged public func removeFromI_buildFiles(_ value: PBXBuildFile)

    @objc(addI_buildFiles:)
    @NSManaged public func addToI_buildFiles(_ values: NSSet)

    @objc(removeI_buildFiles:)
    @NSManaged public func removeFromI_buildFiles(_ values: NSSet)

}

// MARK: Generated accessors for i_projectReference1
extension PBXFileElement {

    @objc(addI_projectReference1Object:)
    @NSManaged public func addToI_projectReference1(_ value: ProjectReference)

    @objc(removeI_projectReference1Object:)
    @NSManaged public func removeFromI_projectReference1(_ value: ProjectReference)

    @objc(addI_projectReference1:)
    @NSManaged public func addToI_projectReference1(_ values: NSSet)

    @objc(removeI_projectReference1:)
    @NSManaged public func removeFromI_projectReference1(_ values: NSSet)

}

// MARK: Generated accessors for i_projectReference2
extension PBXFileElement {

    @objc(addI_projectReference2Object:)
    @NSManaged public func addToI_projectReference2(_ value: ProjectReference)

    @objc(removeI_projectReference2Object:)
    @NSManaged public func removeFromI_projectReference2(_ value: ProjectReference)

    @objc(addI_projectReference2:)
    @NSManaged public func addToI_projectReference2(_ values: NSSet)

    @objc(removeI_projectReference2:)
    @NSManaged public func removeFromI_projectReference2(_ values: NSSet)

}
