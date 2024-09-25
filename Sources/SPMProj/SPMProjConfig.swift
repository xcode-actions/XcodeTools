import Foundation

import Logging



/** A container to hold the properties that can modify the behaviour of the module. */
public enum SPMProjConfig {
	
	public static var logger: Logger? = .init(label: "com.xcode-actions.XcodeProj")
	
}

typealias Conf = SPMProjConfig
