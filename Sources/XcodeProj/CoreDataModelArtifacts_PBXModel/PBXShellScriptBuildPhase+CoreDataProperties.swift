//
//  PBXShellScriptBuildPhase+CoreDataProperties.swift
//  
//
//  Created by François Lamboley on 13/05/2021.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension PBXShellScriptBuildPhase {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PBXShellScriptBuildPhase> {
        return NSFetchRequest<PBXShellScriptBuildPhase>(entityName: "PBXShellScriptBuildPhase")
    }

    @NSManaged public var alwaysOutOfDate: NSNumber?
    @NSManaged public var inputFileListPaths: [String]?
    @NSManaged public var inputPaths: [String]?
    @NSManaged public var outputFileListPaths: [String]?
    @NSManaged public var outputPaths: [String]?
    @NSManaged public var shellPath: String?
    @NSManaged public var shellScript: String?
    @NSManaged public var showEnvVarsInLog: NSNumber?

}
