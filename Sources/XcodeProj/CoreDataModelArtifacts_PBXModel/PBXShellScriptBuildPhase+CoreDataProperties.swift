//
/*
 * PBXShellScriptBuildPhase+CoreDataProperties.swift
 * 
 *
 * Created by François Lamboley on 2025/12/21.
 * 
 */
//  This file was automatically generated and should not be edited.
//

public import Foundation
public import CoreData


public typealias PBXShellScriptBuildPhaseCoreDataPropertiesSet = NSSet

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
