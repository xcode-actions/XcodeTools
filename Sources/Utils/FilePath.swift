import Foundation
#if canImport(System)
import System
#else
import SystemPackage
#endif



public extension FilePath {
	
#if !canImport(System)
	init?(_ url: URL) {
		guard url.isFileURL else {
			return nil
		}
		self.init(url.path)
	}
#endif
	
	var url: URL {
		return URL(fileURLWithPath: string)
	}
	
}
