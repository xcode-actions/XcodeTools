//
/*
 * XCBuildConfiguration+CoreDataProperties.swift
 * 
 *
 * Created by François Lamboley on 2026/09/21.
 * 
 */
//  This file was automatically generated and should not be edited.
//

public import Foundation
public import CoreData


public typealias XCBuildConfigurationCoreDataPropertiesSet = NSSet

extension XCBuildConfiguration {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<XCBuildConfiguration> {
        return NSFetchRequest<XCBuildConfiguration>(entityName: "XCBuildConfiguration")
    }

    @NSManaged nonisolated public var name: String?
    @NSManaged nonisolated public var rawBuildSettings: [String: Any]?
    @NSManaged nonisolated public var baseConfigurationReference: PBXFileReference?
    @NSManaged nonisolated public var i_list: XCConfigurationList?

}
