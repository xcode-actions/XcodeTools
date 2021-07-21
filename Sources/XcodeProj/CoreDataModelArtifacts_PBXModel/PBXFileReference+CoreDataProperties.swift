//
//  PBXFileReference+CoreDataProperties.swift
//  
//
//  Created by François Lamboley on 2021/6/1.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension PBXFileReference {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PBXFileReference> {
        return NSFetchRequest<PBXFileReference>(entityName: "PBXFileReference")
    }

    @NSManaged public var explicitFileType: String?
    @NSManaged public var fileEncoding: NSNumber?
    @NSManaged public var includeInIndex: NSNumber?
    @NSManaged public var lastKnownFileType: String?
    @NSManaged public var lineEnding: NSNumber?
    @NSManaged public var plistStructureDefinitionIdentifier: String?
    @NSManaged public var xcLanguageSpecificationIdentifier: String?
    @NSManaged public var buildConfigurations_: NSSet?
    @NSManaged public var nativeTargets_: NSSet?
    @NSManaged public var variantGroup_: PBXVariantGroup?
    @NSManaged public var versionGroup_: XCVersionGroup?
    @NSManaged public var versionGroupsForCurrentVersion_: NSSet?

}

// MARK: Generated accessors for buildConfigurations_
extension PBXFileReference {

    @objc(addBuildConfigurations_Object:)
    @NSManaged public func addToBuildConfigurations_(_ value: XCBuildConfiguration)

    @objc(removeBuildConfigurations_Object:)
    @NSManaged public func removeFromBuildConfigurations_(_ value: XCBuildConfiguration)

    @objc(addBuildConfigurations_:)
    @NSManaged public func addToBuildConfigurations_(_ values: NSSet)

    @objc(removeBuildConfigurations_:)
    @NSManaged public func removeFromBuildConfigurations_(_ values: NSSet)

}

// MARK: Generated accessors for nativeTargets_
extension PBXFileReference {

    @objc(addNativeTargets_Object:)
    @NSManaged public func addToNativeTargets_(_ value: PBXNativeTarget)

    @objc(removeNativeTargets_Object:)
    @NSManaged public func removeFromNativeTargets_(_ value: PBXNativeTarget)

    @objc(addNativeTargets_:)
    @NSManaged public func addToNativeTargets_(_ values: NSSet)

    @objc(removeNativeTargets_:)
    @NSManaged public func removeFromNativeTargets_(_ values: NSSet)

}

// MARK: Generated accessors for versionGroupsForCurrentVersion_
extension PBXFileReference {

    @objc(addVersionGroupsForCurrentVersion_Object:)
    @NSManaged public func addToVersionGroupsForCurrentVersion_(_ value: XCVersionGroup)

    @objc(removeVersionGroupsForCurrentVersion_Object:)
    @NSManaged public func removeFromVersionGroupsForCurrentVersion_(_ value: XCVersionGroup)

    @objc(addVersionGroupsForCurrentVersion_:)
    @NSManaged public func addToVersionGroupsForCurrentVersion_(_ values: NSSet)

    @objc(removeVersionGroupsForCurrentVersion_:)
    @NSManaged public func removeFromVersionGroupsForCurrentVersion_(_ values: NSSet)

}
