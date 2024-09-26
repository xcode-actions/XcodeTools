import Foundation

import GlobalConfModule
import Logging



public extension ConfKeys {
	/* URLRequestOperation conf namespace declaration. */
	struct XcodeTools {}
	var xcodeTools: XcodeTools {XcodeTools()}
}


extension ConfKeys.XcodeTools {
	
	#declareConfKey("logger", Logging.Logger?.self, defaultValue: .init(label: "com.xcode-actions.XcodeTools"))
	
}


extension Conf {
	
	#declareConfAccessor(\.xcodeTools.logger, Logging.Logger?.self)
	
}
