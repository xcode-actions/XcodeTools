import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import SystemPackage



enum SourceBuilderError : Error {
	
	case buildPhaseError(Error)
	
}

typealias Err = SourceBuilderError
