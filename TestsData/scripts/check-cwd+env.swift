#!/usr/bin/swift
import Foundation


let envName = (CommandLine.argc == 2 ? CommandLine.arguments[1] : nil)

if let envName = envName {
	print(FileManager.default.currentDirectoryPath)
	print(getenv(envName).flatMap{ String(cString: $0) } ?? "<no value>")
} else {
	struct EnvAndCwd : Codable, Equatable {
#if os(macOS)
		static var defaultRemovedKeys = Set<String>(
			arrayLiteral:
				/* Keys removed by spawn (or something else). */
				"DYLD_FALLBACK_LIBRARY_PATH", "DYLD_FALLBACK_FRAMEWORK_PATH", "DYLD_LIBRARY_PATH", "DYLD_FRAMEWORK_PATH",
				/* Keys added by Swift launcher (presumably). */
				"CPATH", "LIBRARY_PATH", "SDKROOT"
		)
#else
		/* Keys added by swift launcher (presumably). */
		static var defaultRemovedKeys = Set<String>(arrayLiteral: "LD_LIBRARY_PATH")
#endif
		
		var cwd: String
		var env: [String: String]
		
		init(removedEnvKeys: Set<String> = Self.defaultRemovedKeys) {
			env = [String: String]()
			cwd = FileManager.default.currentDirectoryPath
			
			/* Fill env */
			var curEnvPtr = environ
			while let curVarValC = curEnvPtr.pointee {
				defer {curEnvPtr = curEnvPtr.advanced(by: 1)}
				let curVarVal = String(cString: curVarValC)
				let split = curVarVal.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false).map(String.init)
				assert(split.count == 2) /* If this assert is false, the environ variable is invalid. As we’re a test script we don’t care about being fully safe. */
				guard !removedEnvKeys.contains(split[0]) else {continue}
				env[split[0]] = split[1] /* Same, if we get the same var twice, environ is invalid so we override without worrying. */
			}
		}
	}
	
	try FileHandle.standardOutput.write(contentsOf: JSONEncoder().encode(EnvAndCwd()))
}
