import Foundation



/* From <https://gist.github.com/dduan/d4e967f3fc2801d3736b726cd34446bc>. */
func withCStrings(_ strings: [String], scoped: ([UnsafeMutablePointer<CChar>?]) throws -> Void) rethrows {
	let cStrings = strings.map{ strdup($0) }
	try scoped(cStrings + [nil])
	cStrings.forEach{ free($0) }
}
