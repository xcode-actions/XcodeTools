import Foundation



/* From <https://forums.swift.org/t/using-indirect-modifier-for-struct-properties/37600/14>. */
@propertyWrapper
public enum Indirect<Wrapped> {
	
	indirect case wrapped(Wrapped)
	
	public init(wrappedValue: Wrapped) {
		self = .wrapped(wrappedValue)
	}
	
	public var wrappedValue: Wrapped {
		get {switch self {case .wrapped(let x): return x}}
		set {self = .wrapped(newValue)}
	}
	
}


extension Indirect : Sendable  where Wrapped : Sendable  {}
extension Indirect : Hashable  where Wrapped : Hashable  {}
extension Indirect : Equatable where Wrapped : Equatable {}

extension Indirect : Codable where Wrapped : Codable {
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		self = .wrapped(try container.decode(Wrapped.self))
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encode(wrappedValue)
	}
	
}
