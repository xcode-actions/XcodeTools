//
/*
 * PBXFileReference+CoreDataProperties.swift
 * 
 *
 * Created by François Lamboley on 2025/12/21.
 * 
 */
//  This file was automatically generated and should not be edited.
//

public import Foundation
public import CoreData


public typealias PBXFileReferenceCoreDataPropertiesSet = NSSet

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
    @NSManaged public var i_buildConfigurations: NSSet?
    @NSManaged public var i_nativeTargets: NSSet?
    @NSManaged public var i_variantGroup: PBXVariantGroup?
    @NSManaged public var i_versionGroup: XCVersionGroup?
    @NSManaged public var i_versionGroupsForCurrentVersion: NSSet?

}

// MARK: Generated accessors for i_buildConfigurations
extension PBXFileReference {

    @objc(addI_buildConfigurationsObject:)
    @NSManaged public func addToI_buildConfigurations(_ value: XCBuildConfiguration)

    @objc(removeI_buildConfigurationsObject:)
    @NSManaged public func removeFromI_buildConfigurations(_ value: XCBuildConfiguration)

    @objc(addI_buildConfigurations:)
    @NSManaged public func addToI_buildConfigurations(_ values: NSSet)

    @objc(removeI_buildConfigurations:)
    @NSManaged public func removeFromI_buildConfigurations(_ values: NSSet)

}

// MARK: Generated accessors for i_nativeTargets
extension PBXFileReference {

    @objc(addI_nativeTargetsObject:)
    @NSManaged public func addToI_nativeTargets(_ value: PBXNativeTarget)

    @objc(removeI_nativeTargetsObject:)
    @NSManaged public func removeFromI_nativeTargets(_ value: PBXNativeTarget)

    @objc(addI_nativeTargets:)
    @NSManaged public func addToI_nativeTargets(_ values: NSSet)

    @objc(removeI_nativeTargets:)
    @NSManaged public func removeFromI_nativeTargets(_ values: NSSet)

}

// MARK: Generated accessors for i_versionGroupsForCurrentVersion
extension PBXFileReference {

    @objc(addI_versionGroupsForCurrentVersionObject:)
    @NSManaged public func addToI_versionGroupsForCurrentVersion(_ value: XCVersionGroup)

    @objc(removeI_versionGroupsForCurrentVersionObject:)
    @NSManaged public func removeFromI_versionGroupsForCurrentVersion(_ value: XCVersionGroup)

    @objc(addI_versionGroupsForCurrentVersion:)
    @NSManaged public func addToI_versionGroupsForCurrentVersion(_ values: NSSet)

    @objc(removeI_versionGroupsForCurrentVersion:)
    @NSManaged public func removeFromI_versionGroupsForCurrentVersion(_ values: NSSet)

}
