import Foundation
import SystemPackage



public extension FilePath {
	
	init?(_ url: URL) {
		guard url.isFileURL else {
			return nil
		}
		self.init(url.path)
	}
	
	var url: URL {
		return URL(fileURLWithPath: string)
	}
	
}
