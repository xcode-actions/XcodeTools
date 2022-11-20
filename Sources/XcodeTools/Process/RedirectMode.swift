import Foundation
#if canImport(System)
import System
#else
import SystemPackage
#endif



/**
 How to redirect stdout and stderr? */
public enum RedirectMode {
	
	/**
	 The stream will be left as-is:
	 all std output from process will be directed to same stdout/stderr as calling process. */
	case none
	case toNull
	case capture
	/**
	 The stream should be redirected to this fd.
	 If `giveOwnership` is true, the fd will be closed when the process is run.
	 Otherwise it is your responsability to close it when needed. */
	case toFd(FileDescriptor, giveOwnership: Bool)
	
}
