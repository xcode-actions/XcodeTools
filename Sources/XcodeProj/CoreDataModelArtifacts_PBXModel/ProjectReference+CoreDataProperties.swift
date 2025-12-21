//
/*
 * ProjectReference+CoreDataProperties.swift
 * 
 *
 * Created by François Lamboley on 2025/12/21.
 * 
 */
//  This file was automatically generated and should not be edited.
//

public import Foundation
public import CoreData


public typealias ProjectReferenceCoreDataPropertiesSet = NSSet

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
