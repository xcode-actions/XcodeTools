//
/*
 * PBXContainerItemProxy+CoreDataProperties.swift
 * 
 *
 * Created by François Lamboley on 2023/09/09.
 * 
 */
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
    @NSManaged public var i_referenceProxies: NSSet?
    @NSManaged public var i_targetDependencies: NSSet?

}

// MARK: Generated accessors for i_referenceProxies
extension PBXContainerItemProxy {

    @objc(addI_referenceProxiesObject:)
    @NSManaged public func addToI_referenceProxies(_ value: PBXReferenceProxy)

    @objc(removeI_referenceProxiesObject:)
    @NSManaged public func removeFromI_referenceProxies(_ value: PBXReferenceProxy)

    @objc(addI_referenceProxies:)
    @NSManaged public func addToI_referenceProxies(_ values: NSSet)

    @objc(removeI_referenceProxies:)
    @NSManaged public func removeFromI_referenceProxies(_ values: NSSet)

}

// MARK: Generated accessors for i_targetDependencies
extension PBXContainerItemProxy {

    @objc(addI_targetDependenciesObject:)
    @NSManaged public func addToI_targetDependencies(_ value: PBXTargetDependency)

    @objc(removeI_targetDependenciesObject:)
    @NSManaged public func removeFromI_targetDependencies(_ value: PBXTargetDependency)

    @objc(addI_targetDependencies:)
    @NSManaged public func addToI_targetDependencies(_ values: NSSet)

    @objc(removeI_targetDependencies:)
    @NSManaged public func removeFromI_targetDependencies(_ values: NSSet)

}
