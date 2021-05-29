//
//  PBXReferenceProxy+CoreDataProperties.swift
//  
//
//  Created by François Lamboley on 2021/5/30.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension PBXReferenceProxy {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PBXReferenceProxy> {
        return NSFetchRequest<PBXReferenceProxy>(entityName: "PBXReferenceProxy")
    }

    @NSManaged public var fileType: String?
    @NSManaged public var remoteRef: PBXContainerItemProxy?

}
