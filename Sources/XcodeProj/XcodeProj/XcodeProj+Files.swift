import CoreData
import Foundation



extension XcodeProj {
	
	public static func onContext_iterateFileElementsForFiles(fileElements: [PBXFileElement], xcodeprojURL: URL, _ handler: (_ fileURL: URL, _ knownFileType: String?) throws -> Void) throws {
		for fileElement in fileElements {
			switch fileElement {
				case let fileRef as PBXFileReference:
					let url = try fileRef.resolvedPathAsURL(xcodeprojURL: xcodeprojURL, variables: BuildSettings.standardDefaultSettingsForResolvingPathsAsDictionary(xcodeprojURL: xcodeprojURL))
					try handler(url, fileRef.lastKnownFileType)
					
				case let group as PBXGroup:
					try onContext_iterateFileElementsForFiles(fileElements: group.getChildren(), xcodeprojURL: xcodeprojURL, handler)
					
				case let refProxy as PBXReferenceProxy:
					let url = try refProxy.resolvedPathAsURL(xcodeprojURL: xcodeprojURL, variables: BuildSettings.standardDefaultSettingsForResolvingPathsAsDictionary(xcodeprojURL: xcodeprojURL))
					try handler(url, refProxy.getFileType())
					
				case let variantGroup as PBXVariantGroup:
					try onContext_iterateFileElementsForFiles(fileElements: variantGroup.getChildren(), xcodeprojURL: xcodeprojURL, handler)
					
				case let versionGroup as XCVersionGroup:
					try onContext_iterateFileElementsForFiles(fileElements: versionGroup.getChildren(), xcodeprojURL: xcodeprojURL, handler)
					
				default:
					throw Err.internalError(.unknownFileElementClass(rawISA: fileElement.rawISA))
			}
		}
	}
	
	public func iterateReferencedFiles(_ handler: (_ fileURL: URL, _ knownFileType: String?) throws -> Void) throws {
		try managedObjectContext.performAndWait{
			try onContext_iterateReferencedFiles(handler)
		}
	}
	
	public func iterateSources(of targetName: String, _ handler: (_ fileURL: URL, _ knownFileType: String?) throws -> Void) throws {
		try managedObjectContext.performAndWait{
			try pbxproj.rootObject.onContext_iterateSources(of: targetName, xcodeprojURL: xcodeprojURL, handler)
		}
	}
	
	public func iterateResources(of targetName: String, _ handler: (_ fileURL: URL, _ knownFileType: String?) throws -> Void) throws {
		try managedObjectContext.performAndWait{
			try pbxproj.rootObject.onContext_iterateResources(of: targetName, xcodeprojURL: xcodeprojURL, handler)
		}
	}
	
	public func getReferencedFiles() throws -> [(fileURL: URL, knownFileType: String?)] {
		return try managedObjectContext.performAndWait{
			try onContext_getReferencedFiles()
		}
	}
	
	public func onContext_iterateReferencedFiles(_ handler: (_ fileURL: URL, _ knownFileType: String?) throws -> Void) throws {
		try pbxproj.rootObject.onContext_iterateReferencedFiles(xcodeprojURL: xcodeprojURL, handler)
	}
	
	public func onContext_getReferencedFiles() throws -> [(fileURL: URL, knownFileType: String?)] {
		var res: [(URL, String?)] = []
		try onContext_iterateReferencedFiles{ res.append(($0, $1)) }
		return res
	}
	
}


extension PBXProject {
	
	public func onContext_iterateSources(of targetName: String, xcodeprojURL: URL, _ handler: (_ fileURL: URL, _ knownFileType: String?) throws -> Void) throws {
		for target in try (getTargets().filter{ try $0.getName() == targetName }) {
			for buildPhase in try target.getBuildPhases().compactMap({ $0 as? PBXSourcesBuildPhase }) {
				/* TODO: The method below will also iterate on children of groups if any, idt it’s what we want/what Xcode does…
				 *       In theory IIUC when the model is correct there shouldn’t be any group elements in the files of a build phase, but idk. */
				try XcodeProj.onContext_iterateFileElementsForFiles(fileElements: buildPhase.getFiles().compactMap{ $0.fileRef }, xcodeprojURL: xcodeprojURL, handler)
			}
		}
	}
	
	public func onContext_iterateResources(of targetName: String, xcodeprojURL: URL, _ handler: (_ fileURL: URL, _ knownFileType: String?) throws -> Void) throws {
		for target in try (getTargets().filter{ try $0.getName() == targetName }) {
			for buildPhase in try target.getBuildPhases().compactMap({ $0 as? PBXResourcesBuildPhase }) {
				/* TODO: Same as in iterateSources. */
				try XcodeProj.onContext_iterateFileElementsForFiles(fileElements: buildPhase.getFiles().compactMap{ $0.fileRef }, xcodeprojURL: xcodeprojURL, handler)
			}
		}
	}
	
	public func onContext_iterateReferencedFiles(xcodeprojURL: URL, _ handler: (_ fileURL: URL, _ knownFileType: String?) throws -> Void) throws {
		try XcodeProj.onContext_iterateFileElementsForFiles(fileElements: getMainGroup().getChildren(), xcodeprojURL: xcodeprojURL, handler)
	}
	
}
