//
//  PBXCopyFilesBuildPhase+CoreDataProperties.swift
//  
//
//  Created by François Lamboley on 13/05/2021.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension PBXCopyFilesBuildPhase {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PBXCopyFilesBuildPhase> {
        return NSFetchRequest<PBXCopyFilesBuildPhase>(entityName: "PBXCopyFilesBuildPhase")
    }

    @NSManaged public var dstPath: String?
    @NSManaged public var dstSubfolderSpec: Int16

}
