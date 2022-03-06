//
//  PBXObject+CoreDataProperties.swift
//  
//
//  Created by François Lamboley on 06/03/2022.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension PBXObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PBXObject> {
        return NSFetchRequest<PBXObject>(entityName: "PBXObject")
    }

    @NSManaged public var rawISA: String?
    @NSManaged public var rawObject: [String: Any]?
    @NSManaged public var xcID: String?

}

extension PBXObject : Identifiable {

}
