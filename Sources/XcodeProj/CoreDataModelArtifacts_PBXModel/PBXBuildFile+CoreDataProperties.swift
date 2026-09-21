//
/*
 * PBXBuildFile+CoreDataProperties.swift
 * 
 *
 * Created by François Lamboley on 2026/09/21.
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

    @NSManaged nonisolated public var rawSettings: [String: Any]?
    @NSManaged nonisolated public var fileRef: PBXFileElement?
    @NSManaged nonisolated public var i_buildPhase: PBXBuildPhase?
    @NSManaged nonisolated public var productRef: XCSwiftPackageProductDependency?

}
