//
/*
 * PBXContainerItemProxy+CoreDataProperties.swift
 * 
 *
 * Created by François Lamboley on 2026/09/21.
 * 
 */
//  This file was automatically generated and should not be edited.
//

public import Foundation
public import CoreData


public typealias PBXContainerItemProxyCoreDataPropertiesSet = NSSet

extension PBXContainerItemProxy {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PBXContainerItemProxy> {
        return NSFetchRequest<PBXContainerItemProxy>(entityName: "PBXContainerItemProxy")
    }

    @NSManaged nonisolated public var containerPortalID: String?
    @NSManaged nonisolated public var proxyType: Int16
    @NSManaged nonisolated public var remoteGlobalIDString: String?
    @NSManaged nonisolated public var remoteInfo: String?
    @NSManaged nonisolated public var i_referenceProxies: NSSet?
    @NSManaged nonisolated public var i_targetDependencies: NSSet?

}

// MARK: Generated accessors for i_referenceProxies
extension PBXContainerItemProxy {

    @objc(addI_referenceProxiesObject:)
    @NSManaged nonisolated public func addToI_referenceProxies(_ value: PBXReferenceProxy)

    @objc(removeI_referenceProxiesObject:)
    @NSManaged nonisolated public func removeFromI_referenceProxies(_ value: PBXReferenceProxy)

    @objc(addI_referenceProxies:)
    @NSManaged nonisolated public func addToI_referenceProxies(_ values: NSSet)

    @objc(removeI_referenceProxies:)
    @NSManaged nonisolated public func removeFromI_referenceProxies(_ values: NSSet)

}

// MARK: Generated accessors for i_targetDependencies
extension PBXContainerItemProxy {

    @objc(addI_targetDependenciesObject:)
    @NSManaged nonisolated public func addToI_targetDependencies(_ value: PBXTargetDependency)

    @objc(removeI_targetDependenciesObject:)
    @NSManaged nonisolated public func removeFromI_targetDependencies(_ value: PBXTargetDependency)

    @objc(addI_targetDependencies:)
    @NSManaged nonisolated public func addToI_targetDependencies(_ values: NSSet)

    @objc(removeI_targetDependencies:)
    @NSManaged nonisolated public func removeFromI_targetDependencies(_ values: NSSet)

}
