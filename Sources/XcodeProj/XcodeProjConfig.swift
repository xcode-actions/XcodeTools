import Foundation

import GlobalConfModule
import Logging



public extension ConfKeys {
	/* URLRequestOperation conf namespace declaration. */
	struct XcodeProj {}
	var xcodeProj: XcodeProj {XcodeProj()}
}


extension ConfKeys.XcodeProj {
	
	#declareConfKey("logger",                   Logging.Logger?.self, defaultValue: .init(label: "com.xcode-actions.XcodeProj"))
	#declareConfKey("allowPBXObjectAllocation", Bool          .self, defaultValue: false)
	
}


extension Conf {
	
	#declareConfAccessor(\.xcodeProj.logger,                   Logging.Logger?.self)
	#declareConfAccessor(\.xcodeProj.allowPBXObjectAllocation, Bool           .self)
	
}
