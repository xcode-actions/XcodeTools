import Foundation

import Utils



public struct BuildSetting {
	
	public enum Location {
		
		case none
		case xcconfiguration(XCBuildConfiguration)
		case xcconfigFile(XCConfigRef, lineID: XCConfig.LineID, for: XCBuildConfiguration?)
		
		public var isXCBuildConfig: Bool {
			switch self {
				case .xcconfiguration:     return true
				case .none, .xcconfigFile: return false
			}
		}
		
		public var isXCConfigFile: Bool {
			return (xcconfigFileURL != nil)
		}
		
		public var xcconfigFileURL: URL? {
			switch self {
				case .xcconfigFile(let ref, _, _): return ref.value.sourceURL
				case .none, .xcconfiguration:      return nil
			}
		}
		
		public var target: PBXTarget? {
			switch self {
				case .none, .xcconfigFile(_, lineID: _, for: .none):
					return nil
					
				case .xcconfiguration(let config), .xcconfigFile(_, lineID: _, for: let config?):
					return config.i_list?.i_target
			}
		}
		
	}
	
	public var key: BuildSettingKey
	public var value: Any
	
	public var location: Location
	
	public var stringValue: String {
		switch value {
			case let s as String:   return s
			case let a as [String]: return a.joined(separator: " ")
			default:
				Conf.logger?.warning("Asked string value of build setting whose value is \(value), which has type \(type(of: value)), which is not standard. Returning an empty String.")
				return ""
		}
	}
	
	public init(laxSerializedKey serializedKey: String, value v: Any, location l: Location, allowCommaSeparatorForParameters: Bool = false) {
		key = BuildSettingKey(laxSerializedKey: serializedKey, allowCommaSeparatorForParameters: allowCommaSeparatorForParameters)
		value = v
		location = l
	}
	
	public init(key: BuildSettingKey, value: Any, location: Location) {
		self.key = key
		self.value = value
		self.location = location
	}
	
}


public typealias BuildSettingRef = Ref<BuildSetting>
