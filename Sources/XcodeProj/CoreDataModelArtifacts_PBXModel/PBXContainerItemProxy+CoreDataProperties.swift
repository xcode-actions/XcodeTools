//
//  PBXContainerItemProxy+CoreDataProperties.swift
//  
//
//  Created by François Lamboley on 2021/6/1.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension PBXContainerItemProxy {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PBXContainerItemProxy> {
        return NSFetchRequest<PBXContainerItemProxy>(entityName: "PBXContainerItemProxy")
    }

    @NSManaged public var containerPortalID: String?
    @NSManaged public var proxyType: Int16
    @NSManaged public var remoteGlobalIDString: String?
    @NSManaged public var remoteInfo: String?
    @NSManaged public var referenceProxies_: NSSet?
    @NSManaged public var targetDependencies_: NSSet?

}

// MARK: Generated accessors for referenceProxies_
extension PBXContainerItemProxy {

    @objc(addReferenceProxies_Object:)
    @NSManaged public func addToReferenceProxies_(_ value: PBXReferenceProxy)

    @objc(removeReferenceProxies_Object:)
    @NSManaged public func removeFromReferenceProxies_(_ value: PBXReferenceProxy)

    @objc(addReferenceProxies_:)
    @NSManaged public func addToReferenceProxies_(_ values: NSSet)

    @objc(removeReferenceProxies_:)
    @NSManaged public func removeFromReferenceProxies_(_ values: NSSet)

}

// MARK: Generated accessors for targetDependencies_
extension PBXContainerItemProxy {

    @objc(addTargetDependencies_Object:)
    @NSManaged public func addToTargetDependencies_(_ value: PBXTargetDependency)

    @objc(removeTargetDependencies_Object:)
    @NSManaged public func removeFromTargetDependencies_(_ value: PBXTargetDependency)

    @objc(addTargetDependencies_:)
    @NSManaged public func addToTargetDependencies_(_ values: NSSet)

    @objc(removeTargetDependencies_:)
    @NSManaged public func removeFromTargetDependencies_(_ values: NSSet)

}
