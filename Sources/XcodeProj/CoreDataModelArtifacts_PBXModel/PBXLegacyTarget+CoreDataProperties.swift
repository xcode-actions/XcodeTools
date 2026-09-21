//
/*
 * PBXLegacyTarget+CoreDataProperties.swift
 * 
 *
 * Created by François Lamboley on 2026/09/21.
 * 
 */
//  This file was automatically generated and should not be edited.
//

public import Foundation
public import CoreData


public typealias PBXLegacyTargetCoreDataPropertiesSet = NSSet

extension PBXLegacyTarget {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PBXLegacyTarget> {
        return NSFetchRequest<PBXLegacyTarget>(entityName: "PBXLegacyTarget")
    }

    @NSManaged nonisolated public var buildArgumentsString: String?
    @NSManaged nonisolated public var buildToolPath: String?
    @NSManaged nonisolated public var buildWorkingDirectory: String?
    @NSManaged nonisolated public var passBuildSettingsInEnvironment: Bool

}
