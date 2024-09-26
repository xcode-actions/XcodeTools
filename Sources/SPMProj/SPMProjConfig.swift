import Foundation

import GlobalConfModule
import Logging



public extension ConfKeys {
	/* URLRequestOperation conf namespace declaration. */
	struct SPMProj {}
	var spmProj: SPMProj {SPMProj()}
}


extension ConfKeys.SPMProj {
	
	#declareConfKey("logger", Logging.Logger?.self, defaultValue: .init(label: "com.xcode-actions.SPMProj"))
	
}


extension Conf {
	
	#declareConfAccessor(\.spmProj.logger, Logging.Logger?.self)
	
}
