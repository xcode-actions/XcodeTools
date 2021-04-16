import Foundation



var oldAction = sigaction()
var oldActionHandlerPtr: OpaquePointer?
let sigIgnOpaque = OpaquePointer(bitPattern: unsafeBitCast(SIG_IGN, to: Int.self))
let sigDflOpaque = OpaquePointer(bitPattern: unsafeBitCast(SIG_DFL, to: Int.self))

sigaction(15, nil, &oldAction)
oldActionHandlerPtr = OpaquePointer(bitPattern: unsafeBitCast(oldAction.__sigaction_u.__sa_handler, to: Int.self))
print("before dispatch: ign: \(oldActionHandlerPtr == sigIgnOpaque)")
print("before dispatch: dfl: \(oldActionHandlerPtr == sigDflOpaque)")
print("before dispatch: mask: \(oldAction.sa_mask)")
print("before dispatch: flags: \(oldAction.sa_flags)")

var newAction = sigaction()
newAction.sa_flags = 0
sigemptyset(&newAction.sa_mask)
newAction.__sigaction_u.__sa_sigaction = { signal, siginfo, threadUserContext in
	print("got \(signal) from sigaction")
}
//newAction.__sigaction_u.__sa_handler = SIG_IGN
let newActionHandlerPtr = OpaquePointer(bitPattern: unsafeBitCast(newAction.__sigaction_u.__sa_handler, to: Int.self))
sigaction(15, &newAction, nil)

sigaction(15, nil, &oldAction)
oldActionHandlerPtr = OpaquePointer(bitPattern: unsafeBitCast(oldAction.__sigaction_u.__sa_handler, to: Int.self))
print("after sigaction: ign: \(oldActionHandlerPtr == sigIgnOpaque)")
print("after sigaction: dfl: \(oldActionHandlerPtr == sigDflOpaque)")
print("after sigaction: newAction: \(oldActionHandlerPtr == newActionHandlerPtr)")
print("after sigaction: mask: \(oldAction.sa_mask)")
print("after sigaction: flags: \(oldAction.sa_flags)")

let s = DispatchSource.makeSignalSource(signal: 15)
s.setEventHandler{
	print("got \(s.data) signal 15 from dispatch")
}
s.resume()

sigaction(15, nil, &oldAction)
oldActionHandlerPtr = OpaquePointer(bitPattern: unsafeBitCast(oldAction.__sigaction_u.__sa_handler, to: Int.self))
print("after dispatch: ign: \(oldActionHandlerPtr == sigIgnOpaque)")
print("after dispatch: dfl: \(oldActionHandlerPtr == sigDflOpaque)")
print("after dispatch: newAction: \(oldActionHandlerPtr == newActionHandlerPtr)")
print("after dispatch: mask: \(oldAction.sa_mask)")
print("after dispatch: flags: \(oldAction.sa_flags)")

usleep(500)
/* raise and kill are not the same in a multi-threaded env */
//raise(15)
kill(getpid(), 15)
sleep(1)