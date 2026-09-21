//
/*
 * XCRemoteSwiftPackageReference+CoreDataProperties.swift
 * 
 *
 * Created by François Lamboley on 2026/09/21.
 * 
 */
//  This file was automatically generated and should not be edited.
//

public import Foundation
public import CoreData


public typealias XCRemoteSwiftPackageReferenceCoreDataPropertiesSet = NSSet

extension XCRemoteSwiftPackageReference {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<XCRemoteSwiftPackageReference> {
        return NSFetchRequest<XCRemoteSwiftPackageReference>(entityName: "XCRemoteSwiftPackageReference")
    }

    @NSManaged nonisolated public var repositoryURL: URL?
    @NSManaged nonisolated public var requirement: [String: Any]?
    @NSManaged nonisolated public var i_projects: NSSet?
    @NSManaged nonisolated public var i_swiftPackageProductDependencies: NSSet?

}

// MARK: Generated accessors for i_projects
extension XCRemoteSwiftPackageReference {

    @objc(addI_projectsObject:)
    @NSManaged nonisolated public func addToI_projects(_ value: PBXProject)

    @objc(removeI_projectsObject:)
    @NSManaged nonisolated public func removeFromI_projects(_ value: PBXProject)

    @objc(addI_projects:)
    @NSManaged nonisolated public func addToI_projects(_ values: NSSet)

    @objc(removeI_projects:)
    @NSManaged nonisolated public func removeFromI_projects(_ values: NSSet)

}

// MARK: Generated accessors for i_swiftPackageProductDependencies
extension XCRemoteSwiftPackageReference {

    @objc(addI_swiftPackageProductDependenciesObject:)
    @NSManaged nonisolated public func addToI_swiftPackageProductDependencies(_ value: XCSwiftPackageProductDependency)

    @objc(removeI_swiftPackageProductDependenciesObject:)
    @NSManaged nonisolated public func removeFromI_swiftPackageProductDependencies(_ value: XCSwiftPackageProductDependency)

    @objc(addI_swiftPackageProductDependencies:)
    @NSManaged nonisolated public func addToI_swiftPackageProductDependencies(_ values: NSSet)

    @objc(removeI_swiftPackageProductDependencies:)
    @NSManaged nonisolated public func removeFromI_swiftPackageProductDependencies(_ values: NSSet)

}
