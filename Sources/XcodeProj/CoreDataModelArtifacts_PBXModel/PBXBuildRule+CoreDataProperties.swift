//
/*
 * PBXBuildRule+CoreDataProperties.swift
 * 
 *
 * Created by François Lamboley on 2026/09/21.
 * 
 */
//  This file was automatically generated and should not be edited.
//

public import Foundation
public import CoreData


public typealias PBXBuildRuleCoreDataPropertiesSet = NSSet

extension PBXBuildRule {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PBXBuildRule> {
        return NSFetchRequest<PBXBuildRule>(entityName: "PBXBuildRule")
    }

    @NSManaged nonisolated public var compilerSpec: String?
    @NSManaged nonisolated public var filePatterns: String?
    @NSManaged nonisolated public var fileType: String?
    @NSManaged nonisolated public var inputFiles: [String]?
    @NSManaged nonisolated public var isEditable: Bool
    @NSManaged nonisolated public var outputFiles: [String]?
    @NSManaged nonisolated public var script: String?
    @NSManaged nonisolated public var i_targets: NSSet?

}

// MARK: Generated accessors for i_targets
extension PBXBuildRule {

    @objc(addI_targetsObject:)
    @NSManaged nonisolated public func addToI_targets(_ value: PBXNativeTarget)

    @objc(removeI_targetsObject:)
    @NSManaged nonisolated public func removeFromI_targets(_ value: PBXNativeTarget)

    @objc(addI_targets:)
    @NSManaged nonisolated public func addToI_targets(_ values: NSSet)

    @objc(removeI_targets:)
    @NSManaged nonisolated public func removeFromI_targets(_ values: NSSet)

}
