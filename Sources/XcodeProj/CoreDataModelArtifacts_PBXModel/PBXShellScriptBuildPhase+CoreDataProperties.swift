//
/*
 * PBXShellScriptBuildPhase+CoreDataProperties.swift
 * 
 *
 * Created by François Lamboley on 2026/09/21.
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

    @NSManaged nonisolated public var alwaysOutOfDate: NSNumber?
    @NSManaged nonisolated public var inputFileListPaths: [String]?
    @NSManaged nonisolated public var inputPaths: [String]?
    @NSManaged nonisolated public var outputFileListPaths: [String]?
    @NSManaged nonisolated public var outputPaths: [String]?
    @NSManaged nonisolated public var shellPath: String?
    @NSManaged nonisolated public var shellScript: String?
    @NSManaged nonisolated public var showEnvVarsInLog: NSNumber?

}
