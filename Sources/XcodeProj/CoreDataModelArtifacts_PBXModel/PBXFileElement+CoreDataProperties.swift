//
//  PBXFileElement+CoreDataProperties.swift
//  
//
//  Created by François Lamboley on 2021/6/1.
//
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
    @NSManaged public var buildFiles_: NSSet?
    @NSManaged public var group_: PBXGroup?
    @NSManaged public var projectReference1_: NSSet?
    @NSManaged public var projectReference2_: NSSet?

}

// MARK: Generated accessors for buildFiles_
extension PBXFileElement {

    @objc(addBuildFiles_Object:)
    @NSManaged public func addToBuildFiles_(_ value: PBXBuildFile)

    @objc(removeBuildFiles_Object:)
    @NSManaged public func removeFromBuildFiles_(_ value: PBXBuildFile)

    @objc(addBuildFiles_:)
    @NSManaged public func addToBuildFiles_(_ values: NSSet)

    @objc(removeBuildFiles_:)
    @NSManaged public func removeFromBuildFiles_(_ values: NSSet)

}

// MARK: Generated accessors for projectReference1_
extension PBXFileElement {

    @objc(addProjectReference1_Object:)
    @NSManaged public func addToProjectReference1_(_ value: ProjectReference)

    @objc(removeProjectReference1_Object:)
    @NSManaged public func removeFromProjectReference1_(_ value: ProjectReference)

    @objc(addProjectReference1_:)
    @NSManaged public func addToProjectReference1_(_ values: NSSet)

    @objc(removeProjectReference1_:)
    @NSManaged public func removeFromProjectReference1_(_ values: NSSet)

}

// MARK: Generated accessors for projectReference2_
extension PBXFileElement {

    @objc(addProjectReference2_Object:)
    @NSManaged public func addToProjectReference2_(_ value: ProjectReference)

    @objc(removeProjectReference2_Object:)
    @NSManaged public func removeFromProjectReference2_(_ value: ProjectReference)

    @objc(addProjectReference2_:)
    @NSManaged public func addToProjectReference2_(_ values: NSSet)

    @objc(removeProjectReference2_:)
    @NSManaged public func removeFromProjectReference2_(_ values: NSSet)

}
