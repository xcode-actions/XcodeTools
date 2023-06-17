import CoreData
import Foundation



/** Represents a build rule, that is the tool to call to compile a given type of file. */
@objc(PBXBuildRule)
public class PBXBuildRule : PBXObject {
	
	open override func fillValues(rawObject: [String : Any], rawObjects: [String : [String : Any]], context: NSManagedObjectContext, decodedObjects: inout [String : PBXObject]) throws {
		try super.fillValues(rawObject: rawObject, rawObjects: rawObjects, context: context, decodedObjects: &decodedObjects)
		
		fileType = try rawObject.getForParse("fileType", xcID)
		filePatterns = try rawObject.getForParse("filePatterns", xcID)
		compilerSpec = try rawObject.getForParse("compilerSpec", xcID)
		
		inputFiles = try rawObject.getForParse("inputFiles", xcID)
		outputFiles = try rawObject.getForParse("outputFiles", xcID)
		
		script = try rawObject.getForParse("script", xcID)
		
		isEditable = try rawObject.getBoolForParse("isEditable", xcID)
	}
	
	open override func knownValuesSerialized(projectName: String) throws -> [String: Any] {
		var mySerialization = [String: Any]()
		mySerialization["fileType"]     = try getFileType()
		mySerialization["filePatterns"] = try getFilePatterns()
		mySerialization["compilerSpec"] = try getCompilerSpec()
		mySerialization["inputFiles"]   = try getInputFiles()
		mySerialization["outputFiles"]  = try getOutputFiles()
		mySerialization["script"]       = try getScript()
		mySerialization["isEditable"]   = isEditable ? "1" : "0"
		
		return try mergeSerialization(super.knownValuesSerialized(projectName: projectName), mySerialization)
	}
	
#warning("Comment below is not true anymore")
	/* (Very) sadly, a throwing computed property is not possible, so we use a function to get the non-optional value.
	 * Otherwise, for the compilerSpec example for instance, I’d very much have liked to have a CoreData property named `compilerSpec_o` for instance
	 * and a computed property defined like so:
	 * var compilerSpec {
	 *    get throws {try PBXObject.getNonOptionalValue(compilerSpec_o, "compilerSpec", xcID)}
	 *    set        {compilerSpec_o = newValue}
	 * }
	 * <https://forums.swift.org/t/proposal-allow-getters-and-setters-to-throw/191> */
	
	public func getCompilerSpec() throws -> String   {try PBXObject.getNonOptionalValue(compilerSpec, "compilerSpec", xcID)}
	public func getFilePatterns() throws -> String   {try PBXObject.getNonOptionalValue(filePatterns, "filePatterns", xcID)}
	public func getFileType()     throws -> String   {try PBXObject.getNonOptionalValue(fileType,     "fileType",     xcID)}
	public func getInputFiles()   throws -> [String] {try PBXObject.getNonOptionalValue(inputFiles,   "inputFiles",   xcID)}
	public func getOutputFiles()  throws -> [String] {try PBXObject.getNonOptionalValue(outputFiles,  "outputFiles",  xcID)}
	public func getScript()       throws -> String   {try PBXObject.getNonOptionalValue(script,       "script",       xcID)}
	
}
