//
//  PBXTargetDependency+CoreDataProperties.swift
//  
//
//  Created by François Lamboley on 06/03/2022.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension PBXTargetDependency {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PBXTargetDependency> {
        return NSFetchRequest<PBXTargetDependency>(entityName: "PBXTargetDependency")
    }

    @NSManaged public var name: String?
    @NSManaged public var platformFilter: String?
    @NSManaged public var productRef: XCSwiftPackageProductDependency?
    @NSManaged public var target: PBXTarget?
    @NSManaged public var target_: PBXTarget?
    @NSManaged public var targetProxy: PBXContainerItemProxy?

}
