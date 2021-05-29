//
//  XCRemoteSwiftPackageReference+CoreDataProperties.swift
//  
//
//  Created by François Lamboley on 2021/5/30.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension XCRemoteSwiftPackageReference {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<XCRemoteSwiftPackageReference> {
        return NSFetchRequest<XCRemoteSwiftPackageReference>(entityName: "XCRemoteSwiftPackageReference")
    }

    @NSManaged public var repositoryURL: URL?
    @NSManaged public var requirement: [String: Any]?
    @NSManaged public var projects_: NSSet?
    @NSManaged public var swiftPackageProductDependencies_: NSSet?

}

// MARK: Generated accessors for projects_
extension XCRemoteSwiftPackageReference {

    @objc(addProjects_Object:)
    @NSManaged public func addToProjects_(_ value: PBXProject)

    @objc(removeProjects_Object:)
    @NSManaged public func removeFromProjects_(_ value: PBXProject)

    @objc(addProjects_:)
    @NSManaged public func addToProjects_(_ values: NSSet)

    @objc(removeProjects_:)
    @NSManaged public func removeFromProjects_(_ values: NSSet)

}

// MARK: Generated accessors for swiftPackageProductDependencies_
extension XCRemoteSwiftPackageReference {

    @objc(addSwiftPackageProductDependencies_Object:)
    @NSManaged public func addToSwiftPackageProductDependencies_(_ value: XCSwiftPackageProductDependency)

    @objc(removeSwiftPackageProductDependencies_Object:)
    @NSManaged public func removeFromSwiftPackageProductDependencies_(_ value: XCSwiftPackageProductDependency)

    @objc(addSwiftPackageProductDependencies_:)
    @NSManaged public func addToSwiftPackageProductDependencies_(_ values: NSSet)

    @objc(removeSwiftPackageProductDependencies_:)
    @NSManaged public func removeFromSwiftPackageProductDependencies_(_ values: NSSet)

}
