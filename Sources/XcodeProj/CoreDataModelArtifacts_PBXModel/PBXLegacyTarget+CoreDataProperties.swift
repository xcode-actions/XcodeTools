//
//  PBXLegacyTarget+CoreDataProperties.swift
//  
//
//  Created by François Lamboley on 2021/5/30.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension PBXLegacyTarget {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PBXLegacyTarget> {
        return NSFetchRequest<PBXLegacyTarget>(entityName: "PBXLegacyTarget")
    }

    @NSManaged public var buildArgumentsString: String?
    @NSManaged public var buildToolPath: String?
    @NSManaged public var buildWorkingDirectory: String?
    @NSManaged public var passBuildSettingsInEnvironment: Bool

}
