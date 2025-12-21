//
/*
 * PBXBuildFile+CoreDataProperties.swift
 * 
 *
 * Created by François Lamboley on 2025/12/21.
 * 
 */
//  This file was automatically generated and should not be edited.
//

public import Foundation
public import CoreData


public typealias PBXBuildFileCoreDataPropertiesSet = NSSet

extension PBXBuildFile {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PBXBuildFile> {
        return NSFetchRequest<PBXBuildFile>(entityName: "PBXBuildFile")
    }

    @NSManaged public var rawSettings: [String: Any]?
    @NSManaged public var fileRef: PBXFileElement?
    @NSManaged public var i_buildPhase: PBXBuildPhase?
    @NSManaged public var productRef: XCSwiftPackageProductDependency?

}
