//
//  PBXBuildRule+CoreDataProperties.swift
//  
//
//  Created by François Lamboley on 2021/5/30.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension PBXBuildRule {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PBXBuildRule> {
        return NSFetchRequest<PBXBuildRule>(entityName: "PBXBuildRule")
    }

    @NSManaged public var compilerSpec: String?
    @NSManaged public var filePatterns: String?
    @NSManaged public var fileType: String?
    @NSManaged public var inputFiles: [String]?
    @NSManaged public var isEditable: Bool
    @NSManaged public var outputFiles: [String]?
    @NSManaged public var script: String?
    @NSManaged public var targets_: NSSet?

}

// MARK: Generated accessors for targets_
extension PBXBuildRule {

    @objc(addTargets_Object:)
    @NSManaged public func addToTargets_(_ value: PBXNativeTarget)

    @objc(removeTargets_Object:)
    @NSManaged public func removeFromTargets_(_ value: PBXNativeTarget)

    @objc(addTargets_:)
    @NSManaged public func addToTargets_(_ values: NSSet)

    @objc(removeTargets_:)
    @NSManaged public func removeFromTargets_(_ values: NSSet)

}
