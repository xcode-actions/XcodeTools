//
/*
 * PBXBuildRule+CoreDataProperties.swift
 * 
 *
 * Created by François Lamboley on 2023/09/09.
 * 
 */
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
    @NSManaged public var i_targets: NSSet?

}

// MARK: Generated accessors for i_targets
extension PBXBuildRule {

    @objc(addI_targetsObject:)
    @NSManaged public func addToI_targets(_ value: PBXNativeTarget)

    @objc(removeI_targetsObject:)
    @NSManaged public func removeFromI_targets(_ value: PBXNativeTarget)

    @objc(addI_targets:)
    @NSManaged public func addToI_targets(_ values: NSSet)

    @objc(removeI_targets:)
    @NSManaged public func removeFromI_targets(_ values: NSSet)

}
