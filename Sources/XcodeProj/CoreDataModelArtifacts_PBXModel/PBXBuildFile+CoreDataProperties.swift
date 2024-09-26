//
/*
 * PBXBuildFile+CoreDataProperties.swift
 * 
 *
 * Created by François Lamboley on 2024/09/26.
 * 
 */
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension PBXBuildFile {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PBXBuildFile> {
        return NSFetchRequest<PBXBuildFile>(entityName: "PBXBuildFile")
    }

    @NSManaged public var rawSettings: [String: Any]?
    @NSManaged public var fileRef: PBXFileElement?
    @NSManaged public var i_buildPhase: PBXBuildPhase?
    @NSManaged public var productRef: XCSwiftPackageProductDependency?

}
