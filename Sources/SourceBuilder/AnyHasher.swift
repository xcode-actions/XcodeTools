import Foundation
import SystemPackage

import Crypto
import StreamReader



public struct AnyHasher : Sendable {
	
	public init<H : HashFunction>(t: H.Type) {
		self.hInit = { t.init() }
		self.update = { var h = ($0 as! H); h.update(bufferPointer: $1); $0 = h }
		self.finalize = {
			let hash = ($0 as! H).finalize()
			return hash.reduce("", { $0 + String(format: "%02x", $1) })
		}
	}
	
	public func hash(of file: FilePath) async throws -> String {
		try await Task.detached{
			let fd = try FileDescriptor.open(file, .readOnly)
			let r = FileDescriptorReader(stream: fd, bufferSize: 1024, bufferSizeIncrement: 1024 /* Should never have to be used */)
			var h = hInit()
			while try r.readData(size: 1024, allowReadingLess: true, { self.update(&h, $0); return !$0.isEmpty }) {}
			return self.finalize(h)
		}.result.get()
	}
	
	private let hInit: @Sendable () -> Any
	private let update: @Sendable (_ hasher: inout Any, _ bufferPointer: UnsafeRawBufferPointer) -> Void
	private let finalize: @Sendable (_ hasher: Any) -> String
	
}
