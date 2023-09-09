//
/*
 * ProjectReference+CoreDataProperties.swift
 * 
 *
 * Created by François Lamboley on 2023/09/09.
 * 
 */
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension ProjectReference {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProjectReference> {
        return NSFetchRequest<ProjectReference>(entityName: "ProjectReference")
    }

    @NSManaged public var i_project: PBXProject?
    @NSManaged public var productGroup: PBXFileElement?
    @NSManaged public var projectRef: PBXFileElement?

}

extension ProjectReference : Identifiable {

}
