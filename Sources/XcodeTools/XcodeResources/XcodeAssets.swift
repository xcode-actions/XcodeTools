import Foundation
import SystemPackage

import Utils



public struct XcodeAssets {
	
	public var url: URL
	
	public init?(url: URL) {
		/* TODO: More colorset validation (check json inside, etc.) */
		guard url.pathExtension.lowercased() == "xcassets" else {
			return nil
		}
		self.url = url
	}
	
	public func iterateColorSets(_ handler: (_ colorSet: ColorSet) throws -> Void) throws {
		guard let path = FilePath(url) else {
			throw Err.internalError("Cannot get FilePath for URL \(url)")
		}
		try FileManager.default.iterateFiles(in: path, include: [Self.colorSetIncludeRegex], handler: { fullPath, relativePath, isDir in
			guard let colorSet = ColorSet(url: fullPath.url) else {
				return true
			}
			try handler(colorSet)
			return true
		})
	}
	
	private static let colorSetIncludeRegex = try! NSRegularExpression(pattern: #".*\.colorset$"#, options: [.caseInsensitive])
	
}
