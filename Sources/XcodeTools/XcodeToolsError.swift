import Foundation
#if canImport(System)
import System
#else
import SystemPackage
#endif



public enum XcodeToolsError : Error {
	
	/**
	 Some methods need `XCT_EXEC_PATH` to be set and throw this error if it is not. */
	case envVarXctExecPathNotSet
	
	case outputReadError(Error)
	case invalidDataEncoding(Data)
	case unexpectedSubprocessExit(terminationStatus: Int32, terminationReason: Process.TerminationReason)
	
	case systemError(Errno)
	case internalError(String)
	
}

typealias Err = XcodeToolsError
