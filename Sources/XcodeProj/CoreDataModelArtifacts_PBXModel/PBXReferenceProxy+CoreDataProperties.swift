//
/*
 * PBXReferenceProxy+CoreDataProperties.swift
 * 
 *
 * Created by François Lamboley on 2025/12/21.
 * 
 */
//  This file was automatically generated and should not be edited.
//

public import Foundation
public import CoreData


public typealias PBXReferenceProxyCoreDataPropertiesSet = NSSet

extension PBXReferenceProxy {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PBXReferenceProxy> {
        return NSFetchRequest<PBXReferenceProxy>(entityName: "PBXReferenceProxy")
    }

    @NSManaged public var fileType: String?
    @NSManaged public var remoteRef: PBXContainerItemProxy?

}
