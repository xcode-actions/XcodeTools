import Foundation

import GlobalConfModule
import Logging



public extension ConfKeys {
	/* URLRequestOperation conf namespace declaration. */
	struct XcodeJsonOutput {}
	var xcodeJsonOutput: XcodeJsonOutput {XcodeJsonOutput()}
}


extension ConfKeys.XcodeJsonOutput {
	
	#declareConfKey("logger", Logging.Logger?.self, defaultValue: .init(label: "com.xcode-actions.XcodeJsonOutput"))
	
}


extension Conf {
	
	#declareConfAccessor(\.xcodeJsonOutput.logger, Logging.Logger?.self)
	
}
