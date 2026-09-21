//
/*
 * PBXTargetDependency+CoreDataProperties.swift
 * 
 *
 * Created by François Lamboley on 2026/09/21.
 * 
 */
//  This file was automatically generated and should not be edited.
//

public import Foundation
public import CoreData


public typealias PBXTargetDependencyCoreDataPropertiesSet = NSSet

extension PBXTargetDependency {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PBXTargetDependency> {
        return NSFetchRequest<PBXTargetDependency>(entityName: "PBXTargetDependency")
    }

    @NSManaged nonisolated public var name: String?
    @NSManaged nonisolated public var platformFilter: String?
    @NSManaged nonisolated public var i_target: PBXTarget?
    @NSManaged nonisolated public var productRef: XCSwiftPackageProductDependency?
    @NSManaged nonisolated public var target: PBXTarget?
    @NSManaged nonisolated public var targetProxy: PBXContainerItemProxy?

}
