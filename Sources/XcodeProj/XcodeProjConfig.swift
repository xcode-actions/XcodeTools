import Foundation

import Logging



/** A container to hold the properties that can modify the behaviour of the module. */
public enum XcodeProjConfig {
	
	/**
	 Set to true to allow allocate unknown objects as `PBXObjects`.
	 
	 If set to `false`, trying to allocate unknown objects will throw an error. */
	public static var allowPBXObjectAllocation = false
	
	public static var logger: Logger? = .init(label: "com.xcode-actions.XcodeProj")
	
}

typealias Conf = XcodeProjConfig
