//
/*
 * XCBuildConfiguration+CoreDataProperties.swift
 * 
 *
 * Created by François Lamboley on 2025/12/21.
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

    @NSManaged public var name: String?
    @NSManaged public var rawBuildSettings: [String: Any]?
    @NSManaged public var baseConfigurationReference: PBXFileReference?
    @NSManaged public var i_list: XCConfigurationList?

}
