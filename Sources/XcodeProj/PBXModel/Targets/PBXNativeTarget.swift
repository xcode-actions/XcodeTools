import CoreData
import Foundation



@objc(PBXNativeTarget)
public class PBXNativeTarget : PBXTarget {
	
	open override class func propertyRenamings() -> [String : String] {
		return super.propertyRenamings().mergingUnambiguous([
			"buildRules_cd": "buildRules",
			"packageProductDependencies_cd": "packageProductDependencies"
		])
	}
	
	open override func fillValues(rawObject: [String : Any], rawObjects: [String : [String : Any]], context: NSManagedObjectContext, decodedObjects: inout [String : PBXObject]) throws {
		try super.fillValues(rawObject: rawObject, rawObjects: rawObjects, context: context, decodedObjects: &decodedObjects)
		
		let productReferenceID: String? = try rawObject.getIfExistsForParse("productReference", xcID)
		productReference = try productReferenceID.flatMap{ try PBXFileReference.onContext_instantiate(id: $0, on: context, rawObjects: rawObjects, decodedObjects: &decodedObjects) }
		
		productType = try rawObject.getForParse("productType", xcID)
		productInstallPath = try rawObject.getIfExistsForParse("productInstallPath", xcID)
		
		let buildRulesIDs: [String]? = try rawObject.getIfExistsForParse("buildRules", xcID)
		buildRules = try buildRulesIDs?.map{ try PBXBuildRule.onContext_instantiate(id: $0, on: context, rawObjects: rawObjects, decodedObjects: &decodedObjects) }
		
		let packageProductDependenciesIDs: [String]? = try rawObject.getIfExistsForParse("packageProductDependencies", xcID)
		packageProductDependencies = try packageProductDependenciesIDs?.map{ try XCSwiftPackageProductDependency.onContext_instantiate(id: $0, on: context, rawObjects: rawObjects, decodedObjects: &decodedObjects) }
	}
	
	public var buildRules: [PBXBuildRule]? {
		get {PBXObject.getOptionalToMany(buildRules_cd, buildRules_isSet)}
		set {(buildRules_cd, buildRules_isSet) = PBXObject.setOptionalToManyTuple(newValue)}
	}
	
	public var packageProductDependencies: [XCSwiftPackageProductDependency]? {
		get {PBXObject.getOptionalToMany(packageProductDependencies_cd, packageProductDependencies_isSet)}
		set {(packageProductDependencies_cd, packageProductDependencies_isSet) = PBXObject.setOptionalToManyTuple(newValue)}
	}
	
	open override func knownValuesSerialized(projectName: String) throws -> [String: Any] {
		var mySerialization = [String: Any]()
		if let r = buildRules                 {mySerialization["buildRules"]                 = try r.getIDsAndCommentsForSerialization("buildRules", xcID, projectName: projectName)}
		if let r = productReference           {mySerialization["productReference"]           = try r.getIDAndCommentForSerialization("productReference", xcID, projectName: projectName)}
		if let p = productInstallPath         {mySerialization["productInstallPath"]         = p}
		if let r = packageProductDependencies {mySerialization["packageProductDependencies"] = try r.getIDsAndCommentsForSerialization("packageProductDependencies", xcID, projectName: projectName)}
		mySerialization["productType"] = try getProductType()
		
		return try mergeSerialization(super.knownValuesSerialized(projectName: projectName), mySerialization)
	}
	
	public func getProductType() throws -> String {try PBXObject.getNonOptionalValue(productType, "productType", xcID)}
	
}
