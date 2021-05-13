//
//  PBXNativeTarget+CoreDataProperties.swift
//  
//
//  Created by François Lamboley on 13/05/2021.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension PBXNativeTarget {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PBXNativeTarget> {
        return NSFetchRequest<PBXNativeTarget>(entityName: "PBXNativeTarget")
    }

    @NSManaged public var buildRules_isSet: Bool
    @NSManaged public var packageProductDependencies_isSet: Bool
    @NSManaged public var productInstallPath: String?
    @NSManaged public var productType: String?
    @NSManaged public var buildRules_cd: NSOrderedSet?
    @NSManaged public var packageProductDependencies_cd: NSOrderedSet?
    @NSManaged public var productReference: PBXFileReference?

}

// MARK: Generated accessors for buildRules_cd
extension PBXNativeTarget {

    @objc(insertObject:inBuildRules_cdAtIndex:)
    @NSManaged public func insertIntoBuildRules_cd(_ value: PBXBuildRule, at idx: Int)

    @objc(removeObjectFromBuildRules_cdAtIndex:)
    @NSManaged public func removeFromBuildRules_cd(at idx: Int)

    @objc(insertBuildRules_cd:atIndexes:)
    @NSManaged public func insertIntoBuildRules_cd(_ values: [PBXBuildRule], at indexes: NSIndexSet)

    @objc(removeBuildRules_cdAtIndexes:)
    @NSManaged public func removeFromBuildRules_cd(at indexes: NSIndexSet)

    @objc(replaceObjectInBuildRules_cdAtIndex:withObject:)
    @NSManaged public func replaceBuildRules_cd(at idx: Int, with value: PBXBuildRule)

    @objc(replaceBuildRules_cdAtIndexes:withBuildRules_cd:)
    @NSManaged public func replaceBuildRules_cd(at indexes: NSIndexSet, with values: [PBXBuildRule])

    @objc(addBuildRules_cdObject:)
    @NSManaged public func addToBuildRules_cd(_ value: PBXBuildRule)

    @objc(removeBuildRules_cdObject:)
    @NSManaged public func removeFromBuildRules_cd(_ value: PBXBuildRule)

    @objc(addBuildRules_cd:)
    @NSManaged public func addToBuildRules_cd(_ values: NSOrderedSet)

    @objc(removeBuildRules_cd:)
    @NSManaged public func removeFromBuildRules_cd(_ values: NSOrderedSet)

}

// MARK: Generated accessors for packageProductDependencies_cd
extension PBXNativeTarget {

    @objc(insertObject:inPackageProductDependencies_cdAtIndex:)
    @NSManaged public func insertIntoPackageProductDependencies_cd(_ value: XCSwiftPackageProductDependency, at idx: Int)

    @objc(removeObjectFromPackageProductDependencies_cdAtIndex:)
    @NSManaged public func removeFromPackageProductDependencies_cd(at idx: Int)

    @objc(insertPackageProductDependencies_cd:atIndexes:)
    @NSManaged public func insertIntoPackageProductDependencies_cd(_ values: [XCSwiftPackageProductDependency], at indexes: NSIndexSet)

    @objc(removePackageProductDependencies_cdAtIndexes:)
    @NSManaged public func removeFromPackageProductDependencies_cd(at indexes: NSIndexSet)

    @objc(replaceObjectInPackageProductDependencies_cdAtIndex:withObject:)
    @NSManaged public func replacePackageProductDependencies_cd(at idx: Int, with value: XCSwiftPackageProductDependency)

    @objc(replacePackageProductDependencies_cdAtIndexes:withPackageProductDependencies_cd:)
    @NSManaged public func replacePackageProductDependencies_cd(at indexes: NSIndexSet, with values: [XCSwiftPackageProductDependency])

    @objc(addPackageProductDependencies_cdObject:)
    @NSManaged public func addToPackageProductDependencies_cd(_ value: XCSwiftPackageProductDependency)

    @objc(removePackageProductDependencies_cdObject:)
    @NSManaged public func removeFromPackageProductDependencies_cd(_ value: XCSwiftPackageProductDependency)

    @objc(addPackageProductDependencies_cd:)
    @NSManaged public func addToPackageProductDependencies_cd(_ values: NSOrderedSet)

    @objc(removePackageProductDependencies_cd:)
    @NSManaged public func removeFromPackageProductDependencies_cd(_ values: NSOrderedSet)

}
