import Foundation

import GlobalConfModule
import SystemPackage



public struct ColorSet {
	
	public let xcAssets: XcodeAssets
	/**
	 Path of this color set in the ``xcAssets``.
	 
	 This is guaranteed to be a relative path. */
	public let relativePath: FilePath
	public let path: FilePath
	
	/**
	 The fully qualified color name, including any parent group folders marked with `provides-namespace`.
	 
	 For example, a color set `Primary.colorset` inside a group `Brand` whose `Contents.json` sets `provides-namespace` to `true` yields “`Brand/Primary`”. */
	public let colorName: String
	
	public init?(relativePath: FilePath, in xcAssets: XcodeAssets) {
		let fm = FileManager.default
		var isDir = ObjCBool(true)
		
		let relativePath = relativePath.lexicallyNormalized()
		guard  relativePath.isRelative,
				!relativePath.components.isEmpty,
				 relativePath.extension?.lowercased() == "colorset",
				let fullPath = xcAssets.path.lexicallyResolving(relativePath),
				/* Check whether the given colorSet path has contents.
				 * We do not check the contents themselves for correctness (yet?). */
				fm.fileExists(atPath: fullPath.appending("Contents.json").string, isDirectory: &isDir), !isDir.boolValue
		else {
			return nil
		}
		self.relativePath = relativePath
		self.path = fullPath
		self.xcAssets = xcAssets
		
		/* Let’s compute the color name.
		 * We should probably do that when accessing the color name and cache the result,
		 *  but because we’re a struct that would require creating a container class for the cache to avoid mutating the ColorSet when accessing `colorName`.
		 * It’s easier to do the computation directly in the init, and it’s not a big deal (for now anyways). */
		let (_, colorNamePath) = relativePath.components.dropLast().reduce((FilePath(), FilePath()), {
			let (currentPath, currentName) = $0
			let newComponent = $1
			let newPath = currentPath.appending(newComponent)
			assert(newPath.isRelative)
			let newName =
				if Self.folderProvidesNamespace(at: xcAssets.path.pushing(newPath)) {currentName.appending(newComponent)}
				else                                                                {currentName}
			return (newPath, newName)
		})
		self.colorName = colorNamePath.appending(relativePath.lastComponent!.stem).string
	}
	
	private static func folderProvidesNamespace(at folderPath: FilePath) -> Bool {
		struct FolderInfo : Decodable {
			var providesNamespace: Bool
			init(from decoder: any Decoder) throws {
				let container = try decoder.container(keyedBy: CodingKeys.self)
				if container.contains(.properties) {
					let propertiesContainer = try container.nestedContainer(keyedBy: PropertiesCodingKeys.self, forKey: .properties)
					self.providesNamespace = try propertiesContainer.decodeIfPresent(Bool.self, forKey: .providesNamespace) ?? false
				} else {
					self.providesNamespace = false
				}
			}
			enum CodingKeys : String, CodingKey {
				case properties
			}
			enum PropertiesCodingKeys : String, CodingKey {
				case providesNamespace = "provides-namespace"
			}
		}
		
		do {
			let contentsURL = folderPath.url.appendingPathComponent("Contents.json")
			return try JSONDecoder().decode(FolderInfo.self, from: Data(contentsOf: contentsURL)).providesNamespace
		} catch {
			Conf[\.xcodeTools.logger]?.warning("Failed decoding whether folder provides namespace.", metadata: ["folder_path": "\(folderPath)", "error": "\(error)"])
			return false
		}
	}
	
}
