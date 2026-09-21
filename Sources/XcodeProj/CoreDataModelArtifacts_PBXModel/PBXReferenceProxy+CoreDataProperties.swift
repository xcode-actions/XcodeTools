//
/*
 * PBXReferenceProxy+CoreDataProperties.swift
 * 
 *
 * Created by François Lamboley on 2026/09/21.
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

    @NSManaged nonisolated public var fileType: String?
    @NSManaged nonisolated public var remoteRef: PBXContainerItemProxy?

}
