import CoreData
import Foundation

import SPMProj



/** 
 Represents a parsed `xcodeproj` bundle.
 
 This struct is Hashable. 
 Two XcodeProj are considered equal if their pbxproj URLs are equal. */
public struct XcodeProj {
	
	public let xcodeprojURL: URL
	public let pbxprojURL: URL
	
	public let pbxproj: PBXProj
	
	public let persistentCoordinator: NSPersistentStoreCoordinator
	
	public let managedObjectModel: NSManagedObjectModel
	public let managedObjectContext: NSManagedObjectContext
	
	/* This should always be used on the managed object context only. */
	public let spmCache = SPMProjCache()
	
	public init(path: String? = nil, autodetectInFolderAtPath: String = ".") throws {
		let xcodeprojPath: String
		if let p = path {
			xcodeprojPath = p
		} else {
			let fm = FileManager.default
			let xcodeprojs = try fm.contentsOfDirectory(atPath: autodetectInFolderAtPath).filter{
				var isDir = ObjCBool(false)
				guard $0.hasSuffix(".xcodeproj") else {return false}
				guard fm.fileExists(atPath: $0, isDirectory: &isDir), isDir.boolValue else {return false}
				guard fm.fileExists(atPath: $0.appending("/project.pbxproj"), isDirectory: &isDir), !isDir.boolValue else {return false}
				return true
			}
			guard let e = xcodeprojs.onlyElement else {
				throw Err.cannotFindSingleXcodeproj
			}
			xcodeprojPath = e
		}
		
		try self.init(xcodeprojURL: URL(fileURLWithPath: xcodeprojPath, isDirectory: true))
	}
	
	public init(xcodeprojURL url: URL) throws {
		xcodeprojURL = url
		pbxprojURL = xcodeprojURL.appendingPathComponent("project.pbxproj", isDirectory: false)
		
		/* *** Load CoreData model *** */
		
		guard let model = ModelSingleton.model else {
			throw Err.internalError(.modelNotFound)
		}
		managedObjectModel = model
		
		let pc = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
		_ = try Result{ try pc.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil) }
			.mapErrorAndGet{ error in Err.internalError(.cannotLoadModel(error)) }
		
		persistentCoordinator = pc
		
		managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
		managedObjectContext.persistentStoreCoordinator = persistentCoordinator
		
		pbxproj = try PBXProj(url: pbxprojURL, context: managedObjectContext)
	}
	
	public var projectName: String {
		return xcodeprojURL.deletingPathExtension().lastPathComponent
	}
	
}


extension XcodeProj : Hashable {
	
	public static func ==(_ lhs: XcodeProj, _ rhs: XcodeProj) -> Bool {
		return lhs.pbxprojURL == rhs.pbxprojURL
	}
	
	public func hash(into hasher: inout Hasher) {
		hasher.combine(pbxprojURL)
	}
	
}
