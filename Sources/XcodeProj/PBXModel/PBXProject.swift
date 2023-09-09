import CoreData
import Foundation



@objc(PBXProject)
public class PBXProject : PBXObject {
	
	open override class func propertyRenamings() -> [String : String] {
		return super.propertyRenamings().mergingUnambiguous([
			"targets_cd": "targets",
			"projectReferences_cd": "projectReferences",
			"packageReferences_cd": "packageReferences"
		])
	}
	
	open override func fillValues(rawObject: [String : Any], rawObjects: [String : [String : Any]], context: NSManagedObjectContext, decodedObjects: inout [String : PBXObject]) throws {
		try super.fillValues(rawObject: rawObject, rawObjects: rawObjects, context: context, decodedObjects: &decodedObjects)
		
		attributes = try rawObject.getIfExistsForParse("attributes", xcID)
		
		compatibilityVersion = try rawObject.getForParse("compatibilityVersion", xcID)
		
		projectDirPath = try rawObject.getForParse("projectDirPath", xcID)
		projectRoot = try rawObject.getIfExistsForParse("projectRoot", xcID)
		if !(projectRoot?.isEmpty ?? true) {
			Conf.logger?.warning("Suspicious non empty value for projectRoot: \(projectRoot ?? "<nil>"). This probably changes nothing, but I can’t guarantee it.")
		}
		
		knownRegions = try rawObject.getForParse("knownRegions", xcID)
		developmentRegion = try rawObject.getForParse("developmentRegion", xcID)
		
		hasScannedForEncodings = try rawObject.getBoolForParse("hasScannedForEncodings", xcID)
		
		let targetIDs: [String] = try rawObject.getForParse("targets", xcID)
		targets = try targetIDs.map{ try PBXTarget.unsafeInstantiate(id: $0, on: context, rawObjects: rawObjects, decodedObjects: &decodedObjects) }
		
		let packageReferenceIDs: [String]? = try rawObject.getIfExistsForParse("packageReferences", xcID)
		packageReferences = try packageReferenceIDs.flatMap{ try $0.map{ try XCRemoteSwiftPackageReference.unsafeInstantiate(id: $0, on: context, rawObjects: rawObjects, decodedObjects: &decodedObjects) } }
		
		let mainGroupIDs: String = try rawObject.getForParse("mainGroup", xcID)
		mainGroup = try PBXGroup.unsafeInstantiate(id: mainGroupIDs, on: context, rawObjects: rawObjects, decodedObjects: &decodedObjects)
		
		let productRefGroupID: String? = try rawObject.getIfExistsForParse("productRefGroup", xcID)
		productRefGroup = try productRefGroupID.flatMap{ try PBXGroup.unsafeInstantiate(id: $0, on: context, rawObjects: rawObjects, decodedObjects: &decodedObjects) }
		
		let buildConfigurationListID: String = try rawObject.getForParse("buildConfigurationList", xcID)
		buildConfigurationList = try XCConfigurationList.unsafeInstantiate(id: buildConfigurationListID, on: context, rawObjects: rawObjects, decodedObjects: &decodedObjects)
		
		if let rawProjectReferences: [[String: String]] = try rawObject.getIfExistsForParse("projectReferences", xcID) {
			projectReferences = try rawProjectReferences.map{ rawProjectReference in
				guard
					let productGroupID = rawProjectReference["ProductGroup"],
					let projectRefID = rawProjectReference["ProjectRef"],
					rawProjectReference.count == 2
				else {
					throw Err.pbxProjParseError(.unknownOrInvalidProjectReference(rawProjectReference), objectID: xcID)
				}
				let projectReference = ProjectReference(context: context)
				projectReference.productGroup = try PBXFileElement.unsafeInstantiate(id: productGroupID, on: context, rawObjects: rawObjects, decodedObjects: &decodedObjects)
				projectReference.projectRef = try PBXFileElement.unsafeInstantiate(id: projectRefID, on: context, rawObjects: rawObjects, decodedObjects: &decodedObjects)
				return projectReference
			}
		}
	}
	
	public var targets: [PBXTarget]? {
		get {targets_cd?.array as! [PBXTarget]?}
		set {targets_cd = newValue.flatMap{ NSOrderedSet(array: $0) }}
	}
	
	public var packageReferences: [XCRemoteSwiftPackageReference]? {
		get {PBXObject.getOptionalToMany(packageReferences_cd, packageReferences_isSet)}
		set {(packageReferences_cd, packageReferences_isSet) = PBXObject.setOptionalToManyTuple(newValue)}
	}
	
	public var projectReferences: [ProjectReference]? {
		get {PBXObject.getOptionalToMany(projectReferences_cd, projectReferences_isSet)}
		set {(projectReferences_cd, projectReferences_isSet) = PBXObject.setOptionalToManyTuple(newValue)}
	}
	
	public override func stringSerializationName(projectName: String) -> String? {
		return "Project object"
	}
	
	open override func knownValuesSerialized(projectName: String) throws -> [String: Any] {
		var mySerialization = [String: Any]()
		if let a = attributes        {mySerialization["attributes"]        = a}
		if let r = projectRoot       {mySerialization["projectRoot"]       = r}
		if let r = projectReferences {mySerialization["projectReferences"] = r}
		if let r = packageReferences {mySerialization["packageReferences"] = try r.getIDsAndCommentsForSerialization("packageReferences", xcID, projectName: projectName)}
		if let r = productRefGroup   {mySerialization["productRefGroup"]   = try r.getIDAndCommentForSerialization("productRefGroup", xcID, projectName: projectName)}
		mySerialization["compatibilityVersion"]   = try getCompatibilityVersion()
		mySerialization["projectDirPath"]         = try getProjectDirPath()
		mySerialization["knownRegions"]           = try getKnownRegions()
		mySerialization["developmentRegion"]      = try getDevelopmentRegion()
		mySerialization["hasScannedForEncodings"] = hasScannedForEncodings ? "1" : "0"
		mySerialization["targets"]                = try getTargets().getIDsAndCommentsForSerialization("targets", xcID, projectName: projectName)
		mySerialization["mainGroup"]              = try getMainGroup().getIDAndCommentForSerialization("mainGroup", xcID, projectName: projectName)
		mySerialization["buildConfigurationList"] = try getBuildConfigurationList().getIDAndCommentForSerialization("buildConfigurationList", xcID, projectName: projectName)
		
		return try mergeSerialization(super.knownValuesSerialized(projectName: projectName), mySerialization)
	}
	
	public func getCompatibilityVersion()   throws -> String              {try PBXObject.getNonOptionalValue(compatibilityVersion,   "compatibilityVersion",   xcID)}
	public func getDevelopmentRegion()      throws -> String              {try PBXObject.getNonOptionalValue(developmentRegion,      "developmentRegion",      xcID)}
	public func getKnownRegions()           throws -> [String]            {try PBXObject.getNonOptionalValue(knownRegions,           "knownRegions",           xcID)}
	public func getProjectDirPath()         throws -> String              {try PBXObject.getNonOptionalValue(projectDirPath,         "projectDirPath",         xcID)}
	public func getBuildConfigurationList() throws -> XCConfigurationList {try PBXObject.getNonOptionalValue(buildConfigurationList, "buildConfigurationList", xcID)}
	public func getMainGroup()              throws -> PBXGroup            {try PBXObject.getNonOptionalValue(mainGroup,              "mainGroup",              xcID)}
	public func getTargets()                throws -> [PBXTarget]         {try PBXObject.getNonOptionalValue(targets,                "targets",                xcID)}
	
	public func getBuildConfigurations() throws -> [XCBuildConfiguration] {
		return try getBuildConfigurationList().getBuildConfigurations()
	}
	
}
