//
/*
 * PBXCopyFilesBuildPhase+CoreDataProperties.swift
 * 
 *
 * Created by François Lamboley on 2026/09/21.
 * 
 */
//  This file was automatically generated and should not be edited.
//

public import Foundation
public import CoreData


public typealias PBXCopyFilesBuildPhaseCoreDataPropertiesSet = NSSet

extension PBXCopyFilesBuildPhase {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PBXCopyFilesBuildPhase> {
        return NSFetchRequest<PBXCopyFilesBuildPhase>(entityName: "PBXCopyFilesBuildPhase")
    }

    @NSManaged nonisolated public var dstPath: String?
    @NSManaged nonisolated public var dstSubfolderSpec: Int16

}
