//
/*
 * XCBuildConfiguration+CoreDataProperties.swift
 * 
 *
 * Created by François Lamboley on 2024/02/28.
 * 
 */
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension XCBuildConfiguration {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<XCBuildConfiguration> {
        return NSFetchRequest<XCBuildConfiguration>(entityName: "XCBuildConfiguration")
    }

    @NSManaged public var name: String?
    @NSManaged public var rawBuildSettings: [String: Any]?
    @NSManaged public var baseConfigurationReference: PBXFileReference?
    @NSManaged public var i_list: XCConfigurationList?

}
