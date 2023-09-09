import Foundation



public extension Sequence {
	
	func checkForEach(onFail error: Error, _ body: (Self.Element) throws -> Bool) throws -> Self {
		for element in self {
			if try !body(element) {
				throw error
			}
		}
		return self
	}
	
}
