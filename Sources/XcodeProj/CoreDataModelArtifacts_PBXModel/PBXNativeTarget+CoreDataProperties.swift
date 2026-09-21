//
/*
 * PBXNativeTarget+CoreDataProperties.swift
 * 
 *
 * Created by François Lamboley on 2026/09/21.
 * 
 */
//  This file was automatically generated and should not be edited.
//

public import Foundation
public import CoreData


public typealias PBXNativeTargetCoreDataPropertiesSet = NSSet

extension PBXNativeTarget {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PBXNativeTarget> {
        return NSFetchRequest<PBXNativeTarget>(entityName: "PBXNativeTarget")
    }

    @NSManaged nonisolated public var buildRules_isSet: Bool
    @NSManaged nonisolated public var packageProductDependencies_isSet: Bool
    @NSManaged nonisolated public var productInstallPath: String?
    @NSManaged nonisolated public var productType: String?
    @NSManaged nonisolated public var buildRules_cd: NSOrderedSet?
    @NSManaged nonisolated public var packageProductDependencies_cd: NSOrderedSet?
    @NSManaged nonisolated public var productReference: PBXFileReference?

}

// MARK: Generated accessors for buildRules_cd
extension PBXNativeTarget {

    @objc(insertObject:inBuildRules_cdAtIndex:)
    @NSManaged nonisolated public func insertIntoBuildRules_cd(_ value: PBXBuildRule, at idx: Int)

    @objc(removeObjectFromBuildRules_cdAtIndex:)
    @NSManaged nonisolated public func removeFromBuildRules_cd(at idx: Int)

    @objc(insertBuildRules_cd:atIndexes:)
    @NSManaged nonisolated public func insertIntoBuildRules_cd(_ values: [PBXBuildRule], at indexes: NSIndexSet)

    @objc(removeBuildRules_cdAtIndexes:)
    @NSManaged nonisolated public func removeFromBuildRules_cd(at indexes: NSIndexSet)

    @objc(replaceObjectInBuildRules_cdAtIndex:withObject:)
    @NSManaged nonisolated public func replaceBuildRules_cd(at idx: Int, with value: PBXBuildRule)

    @objc(replaceBuildRules_cdAtIndexes:withBuildRules_cd:)
    @NSManaged nonisolated public func replaceBuildRules_cd(at indexes: NSIndexSet, with values: [PBXBuildRule])

    @objc(addBuildRules_cdObject:)
    @NSManaged nonisolated public func addToBuildRules_cd(_ value: PBXBuildRule)

    @objc(removeBuildRules_cdObject:)
    @NSManaged nonisolated public func removeFromBuildRules_cd(_ value: PBXBuildRule)

    @objc(addBuildRules_cd:)
    @NSManaged nonisolated public func addToBuildRules_cd(_ values: NSOrderedSet)

    @objc(removeBuildRules_cd:)
    @NSManaged nonisolated public func removeFromBuildRules_cd(_ values: NSOrderedSet)

}

// MARK: Generated accessors for packageProductDependencies_cd
extension PBXNativeTarget {

    @objc(insertObject:inPackageProductDependencies_cdAtIndex:)
    @NSManaged nonisolated public func insertIntoPackageProductDependencies_cd(_ value: XCSwiftPackageProductDependency, at idx: Int)

    @objc(removeObjectFromPackageProductDependencies_cdAtIndex:)
    @NSManaged nonisolated public func removeFromPackageProductDependencies_cd(at idx: Int)

    @objc(insertPackageProductDependencies_cd:atIndexes:)
    @NSManaged nonisolated public func insertIntoPackageProductDependencies_cd(_ values: [XCSwiftPackageProductDependency], at indexes: NSIndexSet)

    @objc(removePackageProductDependencies_cdAtIndexes:)
    @NSManaged nonisolated public func removeFromPackageProductDependencies_cd(at indexes: NSIndexSet)

    @objc(replaceObjectInPackageProductDependencies_cdAtIndex:withObject:)
    @NSManaged nonisolated public func replacePackageProductDependencies_cd(at idx: Int, with value: XCSwiftPackageProductDependency)

    @objc(replacePackageProductDependencies_cdAtIndexes:withPackageProductDependencies_cd:)
    @NSManaged nonisolated public func replacePackageProductDependencies_cd(at indexes: NSIndexSet, with values: [XCSwiftPackageProductDependency])

    @objc(addPackageProductDependencies_cdObject:)
    @NSManaged nonisolated public func addToPackageProductDependencies_cd(_ value: XCSwiftPackageProductDependency)

    @objc(removePackageProductDependencies_cdObject:)
    @NSManaged nonisolated public func removeFromPackageProductDependencies_cd(_ value: XCSwiftPackageProductDependency)

    @objc(addPackageProductDependencies_cd:)
    @NSManaged nonisolated public func addToPackageProductDependencies_cd(_ values: NSOrderedSet)

    @objc(removePackageProductDependencies_cd:)
    @NSManaged nonisolated public func removeFromPackageProductDependencies_cd(_ values: NSOrderedSet)

}
