//
//  PBXBuildFile+CoreDataProperties.swift
//  
//
//  Created by François Lamboley on 13/05/2021.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension PBXBuildFile {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PBXBuildFile> {
        return NSFetchRequest<PBXBuildFile>(entityName: "PBXBuildFile")
    }

    @NSManaged public var rawSettings: [String: Any]?
    @NSManaged public var buildPhase_: PBXBuildPhase?
    @NSManaged public var fileRef: PBXFileElement?
    @NSManaged public var productRef: XCSwiftPackageProductDependency?

}
