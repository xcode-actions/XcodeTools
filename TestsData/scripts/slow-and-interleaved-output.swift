#!/usr/bin/env swift

import Foundation


let stdout = FileHandle.standardOutput
let stderr = FileHandle.standardError


func printStars(count: Int, to fh: FileHandle) throws {
	for _ in 0..<count {
		/* We do not write the whole string directly on purpose. */
		try fh.write(contentsOf: Data("*".utf8))
	}
}


/* ************
   MARK: - Main
   ************ */

guard CommandLine.argc == 3, let n = Int(CommandLine.arguments[1]), let t = TimeInterval(CommandLine.arguments[2]) else {
	try! stderr.write(contentsOf: Data("Usage: \(CommandLine.arguments[0])  max_number_of_stars  time_interval_between_lines\n".utf8))
	exit(1)
}

let group = DispatchGroup()
let queue1 = DispatchQueue(label: "com.xcode-actions-tests.slow-and-interleaved-output.stdout")
let queue2 = DispatchQueue(label: "com.xcode-actions-tests.slow-and-interleaved-output.stderr")

group.enter()
queue1.async{
	for i in 1...n {
		try! printStars(count: i, to: stdout)
		try! stdout.write(contentsOf: Data("\n".utf8))
		Thread.sleep(forTimeInterval: t)
	}
	group.leave()
}

group.enter()
queue2.async{
	for i in 1...n {
		try! printStars(count: (n - i + 1), to: stderr)
		try! stderr.write(contentsOf: Data("\n".utf8))
		Thread.sleep(forTimeInterval: t)
	}
	group.leave()
}

group.wait()
