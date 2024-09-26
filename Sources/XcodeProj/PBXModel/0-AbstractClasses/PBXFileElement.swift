import CoreData
import Foundation

import GlobalConfModule



/* From <http://www.monobjc.net/xcode-project-file-format.html>. */
@objc(PBXFileElement)
public class PBXFileElement : PBXObject {
	
	public enum SourceTree {
		
		init(_ string: String) {
			switch string {
				case "<group>":    self = .group
				case "<unknown>":  self = .unknown
				case "<absolute>": self = .absolute
				default:           self = .variable(string)
			}
		}
		
		case group
		case unknown
		case absolute
		
		/* Known possible variables:
		 *    - SDKROOT
		 *    - SOURCE_ROOT
		 *    - DEVELOPER_DIR
		 *    - BUILT_PRODUCTS_DIR */
		case variable(String)
		
	}
	
	open override class func propertyRenamings() -> [String : String] {
		return super.propertyRenamings().mergingUnambiguous([
			"rawName": "name",
			"rawPath": "path",
			"rawSourceTree": "sourceTree"
		])
	}
	
	open override func fillValues(rawObject: [String : Any], rawObjects: [String : [String : Any]], context: NSManagedObjectContext, decodedObjects: inout [String : PBXObject]) throws {
		try super.fillValues(rawObject: rawObject, rawObjects: rawObjects, context: context, decodedObjects: &decodedObjects)
		
		rawSourceTree = try rawObject.getForParse("sourceTree", xcID)
		
		rawName = try rawObject.getIfExistsForParse("name", xcID)
		rawPath = try rawObject.getIfExistsForParse("path", xcID)
		
		indentWidth = try rawObject.getInt16AsNumberIfExistsForParse("indentWidth", xcID)
		tabWidth = try rawObject.getInt16AsNumberIfExistsForParse("tabWidth", xcID)
		usesTabs = try rawObject.getBoolAsNumberIfExistsForParse("usesTabs", xcID)
		wrapsLines = try rawObject.getBoolAsNumberIfExistsForParse("wrapsLines", xcID)
	}
	
	open override func stringSerializationName(projectName: String) -> String? {
		return name
	}
	
	open override func knownValuesSerialized(projectName: String) throws -> [String: Any] {
		var mySerialization = [String: Any]()
		if let n = rawName                  {mySerialization["name"] = n}
		if let p = rawPath                  {mySerialization["path"] = p}
		if let v = tabWidth?.stringValue    {mySerialization["tabWidth"] = v}
		if let v = indentWidth?.stringValue {mySerialization["indentWidth"] = v}
		if let b = usesTabs?.boolValue      {mySerialization["usesTabs"] = b ? "1" : "0"}
		if let b = wrapsLines?.boolValue    {mySerialization["wrapsLines"] = b ? "1" : "0"}
		mySerialization["sourceTree"] = try getRawSourceTree()
		
		return try mergeSerialization(super.knownValuesSerialized(projectName: projectName), mySerialization)
	}
	
	public func getRawSourceTree() throws -> String {try PBXObject.getNonOptionalValue(rawSourceTree, "rawSourceTree", xcID)}
	
	/** Subclasses can override if needed. */
	open var parent: PBXFileElement? {
		return i_group
	}
	
	public var name: String? {
		rawName ?? rawPath
	}
	
	public var path: String? {
		rawPath
	}
	
	public var sourceTree: SourceTree? {
		return rawSourceTree.flatMap{ SourceTree($0) }
	}
	
	/**
	 Returns the necessary info to get the resolved path of the file element.
	 You can use `resolvedPathAsURL(xcodeprojURL:variables:)` to get the resolved URL directly.
	 
	 The first element of the tuple (`rootVar`) is the name of the variable to which the resolved path is relative to,
	 and the second is the relative path.
	 
	 For instance, for a built product, you can get the result `("BUILT_PRODUCTS_DIR", "The Awesome App.app")`.
	 The full resolved path is the concatenation of the `BUILT_PRODUCTS_DIR` value, `/`, and the relative path.
	 You should use `resolvedPathAsURL(xcodeprojURL:variables:)` to take care of the edge cases…
	 
	 If `rootVar` is `nil`, the path is relative to the xcodeproj path. */
	public var resolvedPathInfo: (rootVar: String?, path: String)? {
		guard let sourceTree = sourceTree else {
			return nil
		}
		
		switch sourceTree {
			case .group:
				if let parent = parent {
					return parent.resolvedPathInfo.flatMap{
						let (rootVar, parentPath) = $0
						if !parentPath.isEmpty {return (rootVar, parentPath + (path.flatMap{ "/" + $0 } ?? ""))}
						else                   {return (rootVar, path ?? "")}
					}
				} else {
					guard let project = (self as? PBXGroup)?.i_projectForMainGroup else {
						Conf.logger?.warning("Got asked the resolved path of file element \(xcID ?? "<unknown object>") which does not have a parent, whose projectForMainGroup_ property is nil (not the main group), and whose source tree is <group>. This is weird and I don’t know how to handle this; returning nil.")
						return nil
					}
					/* I don’t know the role of project.projectRoot.
					 * I tried modifying it on a project, it didn’t change anything I could see, but idk… */
					switch (project.projectDirPath, path) {
						case (let dirPath?, let path?):
							if dirPath.isEmpty   {return (nil, path)}
							else if path.isEmpty {return (nil, dirPath)}
							else                 {return (nil, dirPath + "/" + path)}
							
						case (let path?, nil), (nil, let path?):
							return (nil, path)
							
						case (nil, nil):
							return (nil, "")
					}
				}
				
			case .absolute:
				guard let path = path else {
					return nil
				}
				if !path.starts(with: "/") {
					Conf.logger?.warning("Got an absolute source tree in \(xcID ?? "<unknown object>"), but file element path does not start w/ a slash!")
				}
				return (nil, path)
				
			case .variable(let variable):
				return (variable, path ?? ".")
				
			case .unknown:
				Conf.logger?.warning("Got asked the resolved path of file element \(xcID ?? "<unknown object>") whose source tree is unknown! Returning nil.")
				/* I guess? */
				return nil
		}
	}
	
	public func getResolvedPathInfo() throws -> (rootVar: String?, path: String) {
		return try PBXObject.getNonOptionalValue(resolvedPathInfo, "resolvedPathInfo", xcID)
	}
	
	public func resolvedPathAsURL(xcodeprojURL: URL, variables: [String: String]) throws -> URL {
		func relativeToXcodeproj(_ path: String) -> URL {
			let projectURL = xcodeprojURL.deletingLastPathComponent()
			guard !path.isEmpty else {return projectURL}
			
			return URL(fileURLWithPath: path, relativeTo: projectURL)
		}
		
		switch try getResolvedPathInfo() {
			case (let rootVar?, let path):
				guard let varValue = variables[rootVar] else {
					throw Err.missingVariable(rootVar)
				}
				if varValue.isEmpty  {return relativeToXcodeproj(path)}
				else if path.isEmpty {return relativeToXcodeproj(varValue)}
				else                 {return relativeToXcodeproj(varValue + "/" + path)}
				
			case (_/*nil actually*/, let path):
				return relativeToXcodeproj(path)
		}
	}
	
}
