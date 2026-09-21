import Foundation
import SystemPackage

import Utils



public struct XcodeAssets {
	
	public var path: FilePath
	
	public init?(url: URL) {
		guard let filePath = FilePath(url) else {
			return nil
		}
		self.init(path: filePath)
	}
	
	public init?(path: FilePath) {
		/* TODO: More validation (check json inside, etc.) */
		guard path.extension?.lowercased() == "xcassets" else {
			return nil
		}
		self.path = path
	}
	
	public func iterateColorSets(_ handler: (_ colorSet: ColorSet) throws -> Void) throws {
		try FileManager.default.iterateFiles(in: path, include: [Self.colorSetIncludeRegex], handler: { _, relativePath, _ in
			guard let colorSet = ColorSet(relativePath: relativePath, in: self) else {
				return true
			}
			try handler(colorSet)
			return true
		})
	}
	
	private static let colorSetIncludeRegex = try! NSRegularExpression(pattern: #".*\.colorset$"#, options: [.caseInsensitive])
	
}
