//
/*
 * XCSwiftPackageProductDependency+CoreDataProperties.swift
 * 
 *
 * Created by François Lamboley on 2023/09/09.
 * 
 */
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension XCSwiftPackageProductDependency {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<XCSwiftPackageProductDependency> {
        return NSFetchRequest<XCSwiftPackageProductDependency>(entityName: "XCSwiftPackageProductDependency")
    }

    @NSManaged public var productName: String?
    @NSManaged public var i_buildFiles: NSSet?
    @NSManaged public var i_nativeTargets: NSSet?
    @NSManaged public var i_targetDependencies: NSSet?
    @NSManaged public var package: XCRemoteSwiftPackageReference?

}

// MARK: Generated accessors for i_buildFiles
extension XCSwiftPackageProductDependency {

    @objc(addI_buildFilesObject:)
    @NSManaged public func addToI_buildFiles(_ value: PBXBuildFile)

    @objc(removeI_buildFilesObject:)
    @NSManaged public func removeFromI_buildFiles(_ value: PBXBuildFile)

    @objc(addI_buildFiles:)
    @NSManaged public func addToI_buildFiles(_ values: NSSet)

    @objc(removeI_buildFiles:)
    @NSManaged public func removeFromI_buildFiles(_ values: NSSet)

}

// MARK: Generated accessors for i_nativeTargets
extension XCSwiftPackageProductDependency {

    @objc(addI_nativeTargetsObject:)
    @NSManaged public func addToI_nativeTargets(_ value: PBXNativeTarget)

    @objc(removeI_nativeTargetsObject:)
    @NSManaged public func removeFromI_nativeTargets(_ value: PBXNativeTarget)

    @objc(addI_nativeTargets:)
    @NSManaged public func addToI_nativeTargets(_ values: NSSet)

    @objc(removeI_nativeTargets:)
    @NSManaged public func removeFromI_nativeTargets(_ values: NSSet)

}

// MARK: Generated accessors for i_targetDependencies
extension XCSwiftPackageProductDependency {

    @objc(addI_targetDependenciesObject:)
    @NSManaged public func addToI_targetDependencies(_ value: PBXTargetDependency)

    @objc(removeI_targetDependenciesObject:)
    @NSManaged public func removeFromI_targetDependencies(_ value: PBXTargetDependency)

    @objc(addI_targetDependencies:)
    @NSManaged public func addToI_targetDependencies(_ values: NSSet)

    @objc(removeI_targetDependencies:)
    @NSManaged public func removeFromI_targetDependencies(_ values: NSSet)

}
