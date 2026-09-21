//
/*
 * PBXObject+CoreDataProperties.swift
 * 
 *
 * Created by François Lamboley on 2026/09/21.
 * 
 */
//  This file was automatically generated and should not be edited.
//

public import Foundation
public import CoreData


public typealias PBXObjectCoreDataPropertiesSet = NSSet

extension PBXObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PBXObject> {
        return NSFetchRequest<PBXObject>(entityName: "PBXObject")
    }

    @NSManaged nonisolated public var rawISA: String?
    @NSManaged nonisolated public var rawObject: [String: Any]?
    @NSManaged nonisolated public var xcID: String?

}

extension PBXObject : Identifiable {

}
