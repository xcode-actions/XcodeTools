//
//  XCSwiftPackageProductDependency+CoreDataProperties.swift
//  
//
//  Created by François Lamboley on 13/05/2021.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension XCSwiftPackageProductDependency {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<XCSwiftPackageProductDependency> {
        return NSFetchRequest<XCSwiftPackageProductDependency>(entityName: "XCSwiftPackageProductDependency")
    }

    @NSManaged public var productName: String?
    @NSManaged public var buildFiles_: NSSet?
    @NSManaged public var nativeTargets_: NSSet?
    @NSManaged public var package: XCRemoteSwiftPackageReference?
    @NSManaged public var targetDependencies_: NSSet?

}

// MARK: Generated accessors for buildFiles_
extension XCSwiftPackageProductDependency {

    @objc(addBuildFiles_Object:)
    @NSManaged public func addToBuildFiles_(_ value: PBXBuildFile)

    @objc(removeBuildFiles_Object:)
    @NSManaged public func removeFromBuildFiles_(_ value: PBXBuildFile)

    @objc(addBuildFiles_:)
    @NSManaged public func addToBuildFiles_(_ values: NSSet)

    @objc(removeBuildFiles_:)
    @NSManaged public func removeFromBuildFiles_(_ values: NSSet)

}

// MARK: Generated accessors for nativeTargets_
extension XCSwiftPackageProductDependency {

    @objc(addNativeTargets_Object:)
    @NSManaged public func addToNativeTargets_(_ value: PBXNativeTarget)

    @objc(removeNativeTargets_Object:)
    @NSManaged public func removeFromNativeTargets_(_ value: PBXNativeTarget)

    @objc(addNativeTargets_:)
    @NSManaged public func addToNativeTargets_(_ values: NSSet)

    @objc(removeNativeTargets_:)
    @NSManaged public func removeFromNativeTargets_(_ values: NSSet)

}

// MARK: Generated accessors for targetDependencies_
extension XCSwiftPackageProductDependency {

    @objc(addTargetDependencies_Object:)
    @NSManaged public func addToTargetDependencies_(_ value: PBXTargetDependency)

    @objc(removeTargetDependencies_Object:)
    @NSManaged public func removeFromTargetDependencies_(_ value: PBXTargetDependency)

    @objc(addTargetDependencies_:)
    @NSManaged public func addToTargetDependencies_(_ values: NSSet)

    @objc(removeTargetDependencies_:)
    @NSManaged public func removeFromTargetDependencies_(_ values: NSSet)

}
