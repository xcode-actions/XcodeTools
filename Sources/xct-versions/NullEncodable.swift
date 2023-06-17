import Foundation



/* From <https://stackoverflow.com/a/62312021>. */
@propertyWrapper
struct NullEncodable<T>: Encodable where T: Encodable {
	
	var wrappedValue: T?
	
	init(wrappedValue: T?) {
		self.wrappedValue = wrappedValue
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		switch wrappedValue {
			case .some(let value): try container.encode(value)
			case .none: try container.encodeNil()
		}
	}
	
}
