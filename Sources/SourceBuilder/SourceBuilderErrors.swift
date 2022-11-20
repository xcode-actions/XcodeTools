import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
#if canImport(System)
import System
#else
import SystemPackage
#endif



enum SourceBuilderError : Error {
	
	case buildPhaseError(Error)
	
}

typealias Err = SourceBuilderError
