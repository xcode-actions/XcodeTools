//
/*
 * PBXFileReference+CoreDataProperties.swift
 * 
 *
 * Created by François Lamboley on 2026/09/21.
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

    @NSManaged nonisolated public var explicitFileType: String?
    @NSManaged nonisolated public var fileEncoding: NSNumber?
    @NSManaged nonisolated public var includeInIndex: NSNumber?
    @NSManaged nonisolated public var lastKnownFileType: String?
    @NSManaged nonisolated public var lineEnding: NSNumber?
    @NSManaged nonisolated public var plistStructureDefinitionIdentifier: String?
    @NSManaged nonisolated public var xcLanguageSpecificationIdentifier: String?
    @NSManaged nonisolated public var i_buildConfigurations: NSSet?
    @NSManaged nonisolated public var i_nativeTargets: NSSet?
    @NSManaged nonisolated public var i_variantGroup: PBXVariantGroup?
    @NSManaged nonisolated public var i_versionGroup: XCVersionGroup?
    @NSManaged nonisolated public var i_versionGroupsForCurrentVersion: NSSet?

}

// MARK: Generated accessors for i_buildConfigurations
extension PBXFileReference {

    @objc(addI_buildConfigurationsObject:)
    @NSManaged nonisolated public func addToI_buildConfigurations(_ value: XCBuildConfiguration)

    @objc(removeI_buildConfigurationsObject:)
    @NSManaged nonisolated public func removeFromI_buildConfigurations(_ value: XCBuildConfiguration)

    @objc(addI_buildConfigurations:)
    @NSManaged nonisolated public func addToI_buildConfigurations(_ values: NSSet)

    @objc(removeI_buildConfigurations:)
    @NSManaged nonisolated public func removeFromI_buildConfigurations(_ values: NSSet)

}

// MARK: Generated accessors for i_nativeTargets
extension PBXFileReference {

    @objc(addI_nativeTargetsObject:)
    @NSManaged nonisolated public func addToI_nativeTargets(_ value: PBXNativeTarget)

    @objc(removeI_nativeTargetsObject:)
    @NSManaged nonisolated public func removeFromI_nativeTargets(_ value: PBXNativeTarget)

    @objc(addI_nativeTargets:)
    @NSManaged nonisolated public func addToI_nativeTargets(_ values: NSSet)

    @objc(removeI_nativeTargets:)
    @NSManaged nonisolated public func removeFromI_nativeTargets(_ values: NSSet)

}

// MARK: Generated accessors for i_versionGroupsForCurrentVersion
extension PBXFileReference {

    @objc(addI_versionGroupsForCurrentVersionObject:)
    @NSManaged nonisolated public func addToI_versionGroupsForCurrentVersion(_ value: XCVersionGroup)

    @objc(removeI_versionGroupsForCurrentVersionObject:)
    @NSManaged nonisolated public func removeFromI_versionGroupsForCurrentVersion(_ value: XCVersionGroup)

    @objc(addI_versionGroupsForCurrentVersion:)
    @NSManaged nonisolated public func addToI_versionGroupsForCurrentVersion(_ values: NSSet)

    @objc(removeI_versionGroupsForCurrentVersion:)
    @NSManaged nonisolated public func removeFromI_versionGroupsForCurrentVersion(_ values: NSSet)

}
