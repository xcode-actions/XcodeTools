import Foundation

import SystemPackage



public struct SignalHandling {
	
	public typealias OriginalHandlerAction = (_ signal: Signal, _ allowRunningSigaction: (_ runOriginalAction: Bool) -> Void) -> Void
	
	public struct UnsigactionID : Hashable {
		
		private static var latestID = 0
		
		internal var id: Int
		internal var signal: Signal
		
		internal init(signal: Signal) {
			defer {Self.latestID += 1}
			self.id = Self.latestID
			self.signal = signal
		}
		
		public static func ==(_ lhs: UnsigactionID, _ rhs: UnsigactionID) -> Bool {
			return lhs.id == rhs.id
		}
		
		public func hash(into hasher: inout Hasher) {
			hasher.combine(id)
		}
		
	}
	
	/**
	Installs the given sigaction and returns the old one if different. Returns
	the old sigaction if different than the new one.
	
	It is a programer error to install a sigaction after unsigactioning a signal,
	before the signal has been fully unsigactioned. Behaviour will be undefined
	if you do it. */
	@discardableResult
	public static func installSigaction(signal: Signal, action newSigaction: Sigaction) throws -> Sigaction? {
		var oldCAction = sigaction()
		var newCAction = newSigaction.rawValue
		guard sigaction(signal.rawValue, &newCAction, &oldCAction) == 0 else {
			throw SignalHandlingError.systemError(Errno(rawValue: errno))
		}
		let oldSigaction = Sigaction(rawValue: oldCAction)
		if oldSigaction != newSigaction {return oldSigaction}
		else                            {return nil}
	}
	
	/**
	Check if the given signal is ignored using `sigaction`. */
	public static func isSignalIgnored(_ signal: Signal) throws -> Bool {
		return try Sigaction(signal: signal).handler == .ignoreHandler
	}
	
	/**
	Check if the given signal is handled with default action using `sigaction`. */
	public static func isSignalDefaultAction(_ signal: Signal) throws -> Bool {
		return try Sigaction(signal: signal).handler == .defaultHandler
	}
	
	/**
	Will force the current signal to be ignored from the sigaction PoV, and
	handle the signal using a `DispatchSourceSignal`.
	
	This is useful to use a `DispatchSourceSignal`, because GCD will not change
	the sigaction when creating the source, and thus, the sigaction _will be
	executed_ even if a dispatch source signal is setup for the given signal.
	
	**Example**: If you register a dispatch source signal for the signal 15 but
	does not ensure signal 15 is ignored, when you receive this signal your
	program will stop because the default handler for this signal is to quit.
	
	All unsigaction IDs must be released for the original sigaction to be set on
	the signal again.
	
	- Note: On Linux, the `DispatchSourceSignal` does change the `sigaction` for
	the signal: https://github.com/apple/swift-corelibs-libdispatch/pull/560
	That’s one more reason to unsigaction the signal before handling it with GCD. */
	public static func retainUnsigactionedSignal(_ signal: Signal, originalHandlerAction: @escaping OriginalHandlerAction) throws -> UnsigactionID {
		return try UnsigactionedSignal.signalProcessingQueue.sync{
			try retainUnsigactionedSignalOnQueue(signal, originalHandlerAction: originalHandlerAction)
		}
	}
	
	/**
	Do **NOT** call this from the `originalHandlerAction` you give when
	unsigactioning a signal. */
	public static func releaseUnsigactionedSignal(_ id: UnsigactionID) throws {
		try UnsigactionedSignal.signalProcessingQueue.sync{
			try releaseUnsigactionedSignalOnQueue(id)
		}
	}
	
	/**
	Convenience to unsigaction multiple signals in one function call.
	
	If one of the signal cannot be unsigactioned, the other signals that were
	successfully unsigactioned will be resigactioned. Of course this can fail
	too, in which case an error will be logged (but nothing more will be done). */
	public static func retainUnsigactionSignals(_ signals: Set<Signal>, originalHandlerAction: @escaping OriginalHandlerAction) throws -> [Signal: UnsigactionID] {
		return try UnsigactionedSignal.signalProcessingQueue.sync{
			var ret = [Signal: UnsigactionID]()
			for signal in signals {
				do {
					ret[signal] = try retainUnsigactionedSignalOnQueue(signal, originalHandlerAction: originalHandlerAction)
				} catch {
					for (signal, UnsigactionID) in ret {
						do    {try releaseUnsigactionedSignalOnQueue(UnsigactionID)}
						catch {SignalHandlingConfig.logger?.error("Cannot release unsigactioned signal \(signal) in recovery handler of unsigactionSignals. The signal will stay ignored, probably forever.")}
					}
					throw error
				}
			}
			return ret
		}
	}
	
	private struct UnsigactionedSignal {
		
		static let signalProcessingQueue = DispatchQueue(label: "com.xcode-actions.unsigactioned-signal-processing")
		static var threadForSignalResend: pthread_t? = {
			var threadAttr = pthread_attr_t()
			let threadAttrInitSuccess = (pthread_attr_init(&threadAttr) == 0)
			defer {
				if threadAttrInitSuccess {
					if pthread_attr_destroy(&threadAttr) != 0 {
						SignalHandlingConfig.logger?.error("Cannot destroy thread attr for thread for signal resend. Leaking.")
					}
				}
			}
			/* Setting thread attributes if attributes init succeeded. */
			if threadAttrInitSuccess {
				if pthread_attr_setdetachstate(&threadAttr, PTHREAD_CREATE_DETACHED) != 0 {
					SignalHandlingConfig.logger?.error("Cannot set detached attribute on thread attr for thread for signal resend.")
				}
				if pthread_attr_set_qos_class_np(&threadAttr, QOS_CLASS_BACKGROUND, QOS_MIN_RELATIVE_PRIORITY) != 0 {
					SignalHandlingConfig.logger?.error("Cannot set QOS attribute on thread attr for thread for signal resend.")
				}
			}
			
			/* Will be left in the thread */
			groupForSyncOfSignalResend.enter()
			
			/* Create and start the thread */
			var thread: pthread_t?
			guard pthread_create(&thread, &threadAttr, threadForSignalResendMain, nil) == 0, thread != nil else {
				SignalHandlingConfig.logger?.error("Cannot create thread for signal resend; resending signals will probably fail.")
				/* Let’s not forget to leave the group as the thread did not start. */
				groupForSyncOfSignalResend.leave()
				return nil
			}
			
			/* Let’s wait for the thread to be started. If we don’t, we might get a
			 * race when signal is resent to this thread and signal might not be
			 * processed. Note that even with this wait I think we might get a race
			 * if the signal is sent before sigsuspend has not started. */
			groupForSyncOfSignalResend.wait()
			return thread
		}()
		
		var originalSigaction: Sigaction
		
		var dispatchSource: DispatchSourceSignal
		var unsigactionInfo = [UnsigactionID: OriginalHandlerAction]()
		
	}
	
	private static var unsigactionedSignals = [Signal: UnsigactionedSignal]()
	
	/** Must always be called on the `UnsigactionedSignal.signalProcessingQueue`. */
	private static func retainUnsigactionedSignalOnQueue(_ signal: Signal, originalHandlerAction: @escaping OriginalHandlerAction) throws -> UnsigactionID {
		/* Whether the signal was retained before or not, we re-install the ignore
		 * handler on the given signal. */
		let oldSigaction = try installSigaction(signal: signal, action: .ignoreAction)
		
		let unsigactionID = UnsigactionID(signal: signal)
		
		var unsigactionedSignal: UnsigactionedSignal
		if let us = unsigactionedSignals[signal] {
			unsigactionedSignal = us
			if let oldSigaction = oldSigaction {
				/* The sigaction has been modified by someone else. We update our
				 * original sigaction to the new sigaction.
				 * Clients should not do that though. */
				unsigactionedSignal.originalSigaction = oldSigaction
				SignalHandlingConfig.logger?.warning("sigaction handler modified for an unsigactioned signal; the sigaction has been reset to ignore", metadata: ["signal": "\(signal)"])
			}
		} else {
			let dispatchSourceSignal = DispatchSource.makeSignalSource(signal: signal.rawValue, queue: UnsigactionedSignal.signalProcessingQueue)
			dispatchSourceSignal.setEventHandler{ [weak dispatchSourceSignal] in
				guard let dispatchSourceSignal = dispatchSourceSignal else {
					SignalHandlingConfig.logger?.error("INTERNAL ERROR: Event handler called, but dispatch source is nil", metadata: ["signal": "\(signal)"])
					return
				}
				SignalHandling.processSignalsOnQueue(signal: signal, count: dispatchSourceSignal.data)
			}
			dispatchSourceSignal.activate()
			unsigactionedSignal = UnsigactionedSignal(originalSigaction: oldSigaction ?? .ignoreAction, dispatchSource: dispatchSourceSignal)
		}
		
		assert(unsigactionedSignal.unsigactionInfo[unsigactionID] == nil)
		unsigactionedSignal.unsigactionInfo[unsigactionID] = originalHandlerAction
		unsigactionedSignals[signal] = unsigactionedSignal
		
		return unsigactionID
	}
	
	/** Must always be called on the `UnsigactionedSignal.signalProcessingQueue`. */
	public static func releaseUnsigactionedSignalOnQueue(_ id: UnsigactionID) throws {
		guard var unsigactionedSignal = unsigactionedSignals[id.signal] else {
			/* We trust our source not to have an internal logic error. If the
			 * unsigactioned signal is not found, it is because the callee called
			 * release twice on the same unsigaction ID. */
			SignalHandlingConfig.logger?.error("Overrelease of unsigation", metadata: ["signal": "\(id.signal)"])
			return
		}
		assert(!unsigactionedSignal.unsigactionInfo.isEmpty, "INTERNAL ERROR: unsigactionInfo should never be empty because when it is, the whole unsigactioned signal should be removed.")
		
		guard unsigactionedSignal.unsigactionInfo.removeValue(forKey: id) != nil else {
			/* Same here. If the unsigaction ID was not in the unsigactionInfo, it
			 * can only be because the callee called release twice on the same ID. */
			SignalHandlingConfig.logger?.error("Overrelease of unsigation for signal: \(id.signal)")
			return
		}
		
		if !unsigactionedSignal.unsigactionInfo.isEmpty {
			/* We have nothing more to do except update the unsigactioned signals:
			 * there are more unsigaction(s) that have been registered for this
			 * signal, so we cannot touch the sigaction handler. */
			unsigactionedSignals[id.signal] = unsigactionedSignal
			return
		}
		
		/* Now we have removed **all** unsigactions on the given signal. Let’s
		 * restore the signal to the state before unsigactions. */
		try installSigaction(signal: id.signal, action: unsigactionedSignal.originalSigaction)
		unsigactionedSignal.dispatchSource.cancel()
		
		/* Finally, once the sigaction has been restored to the original value, we
		 * can remove the unsigactioned signal from the list. */
		unsigactionedSignals.removeValue(forKey: id.signal)
	}
	
	/** Must always be called on the `UnsigactionedSignal.signalProcessingQueue`. */
	private static func processSignalsOnQueue(signal: Signal, count: UInt) {
		SignalHandlingConfig.logger?.debug("Processing signals, called from libdispatch", metadata: ["signal": "\(signal)", "count": "\(count)"])
		
		/* Get the original sigaction for the given signal. */
		guard let unsigactionedSignal = unsigactionedSignals[signal] else {
			SignalHandlingConfig.logger?.error("INTERNAL ERROR: nil unsigactioned signal.", metadata: ["signal": "\(signal)"])
			return
		}
		SignalHandlingConfig.logger?.trace("Original sigaction: \(unsigactionedSignal.originalSigaction)", metadata: ["signal": "\(signal)"])
		
		for _ in 0..<count {
			let group = DispatchGroup()
			var runOriginalHandlerFinal = true
			for (_, originalHandlerAction) in unsigactionedSignal.unsigactionInfo {
				group.enter()
				originalHandlerAction(signal, { runOriginalHandler in
					runOriginalHandlerFinal = runOriginalHandlerFinal && runOriginalHandler
					group.leave()
				})
			}
			group.wait()
			if runOriginalHandlerFinal {
				SignalHandlingConfig.logger?.trace("Resending signal", metadata: ["signal": "\(signal)"])
				resendSignalOnQueue(signal: signal, originalSigaction: unsigactionedSignal.originalSigaction)
			} else {
				SignalHandlingConfig.logger?.trace("Signal resend skipped", metadata: ["signal": "\(signal)"])
			}
		}
	}
	
	/** Must always be called on the `UnsigactionedSignal.signalProcessingQueue`. */
	private static func resendSignalOnQueue(signal: Signal, originalSigaction: Sigaction) {
		do {
			/* Let’s make sure resending the signal is worth it. If the original
			 * sigaction is to ignore the signal, we don’t resend it. */
			guard originalSigaction != .ignoreAction else {
				SignalHandlingConfig.logger?.trace("Original sigaction is ignore; not resending signal", metadata: ["signal": "\(signal)"])
				return
			}
			
			/* Install the original sigaction temporarily. */
			let back = try installSigaction(signal: signal, action: originalSigaction)
			
			/* Retrieve the thread to which to send the signal. See below why. */
			let thread = UnsigactionedSignal.threadForSignalResend ?? pthread_self()
			
			/* Block the thread when it receives the signal. Unblock when action to
			 * be done by the thread is set. */
			semaphoreForSyncOfSignalResend.wait()
			assert(signalResendAction.isNone)
			
			/* We send a signal to the thread directly. libdispatch uses kqueue (on
			 * BSD, signalfd on Linux) and thus signals sent to threads are not
			 * caught. Seems mostly true on Linux, but might require some tweaking.
			 * These signals are not caught by libdispatch… but signals are process
			 * wide! And the sigaction is still executed. So we can reset the
			 * sigaction to the original value, send the signal to the thread, and
			 * set it back to ignore after that. The original signal handler will
			 * be executed.
			 *
			 * Both methods (raise and pthread_kill) work for raising the signal
			 * w/o being caught by libdispatch.
			 * pthread_kill might be safer, because it should really not be caught
			 * by libdispatch, while raise might (it should not either, but it is
			 * less clear; IIUC in a multithreaded env it should never be caught
			 * though).
			 * Anyway, we need to reinstall the sigaction handler after the signal
			 * has been sent and processed, so we need to have some control, which
			 * raise do not give. */
			SignalHandlingConfig.logger?.trace("Sending kill signal to thread \(thread)", metadata: ["signal": "\(signal)"])
//			let ret = raise(signal.rawValue)
			let ret = pthread_kill(thread, signal.rawValue)
			guard ret == 0 else {
				SignalHandlingConfig.logger?.error("Cannot send signal to thread: error \(Errno(rawValue: ret)).", metadata: ["signal": "\(signal)"])
				/* We must reset the sigaction to the previous value as the thread
				 * will probably not wake… */
				if let back = back {
					do    {try installSigaction(signal: signal, action: back)}
					catch {SignalHandlingConfig.logger?.error("Error installing sigaction back to ignore after error sending signal to thread.", metadata: ["signal": "\(signal)"])}
				}
				/* And also signal the semaphore for the thread sync. */
				semaphoreForSyncOfSignalResend.signal()
				return
			}
			
			/* Reinstalling the sigaction handler directly here does not work: the
			 * signal will be ignored before it will have time to be sent on its
			 * thread by pthread_kill. We have to wait for sigsuspend to return.
			 * We instruct the thread to do the installation, then we wait until
			 * it’s done. */
			if let back = back {
				signalResendAction = .reinstallSigactionAndLeaveGroup(signal, back)
				groupForSyncOfSignalResend.enter()
			}
			semaphoreForSyncOfSignalResend.signal()
			
			/* We wait for the thread to do its thing if needed. */
			if back != nil {
				groupForSyncOfSignalResend.wait()
			}
		} catch {
			SignalHandlingConfig.logger?.error("Error installing a sigaction when sending original signal back. Signal is dropped.", metadata: ["signal": "\(signal)"])
		}
	}
	
	private init() {}
	
}


private extension OpaquePointer {
	
	init?(sigHandler: sig_t?) {
		self.init(bitPattern: unsafeBitCast(sigHandler, to: Int.self))
	}
	
}



private enum SignalResendAction {
	
	case none
	case reinstallSigactionAndLeaveGroup(Signal, Sigaction)
	case end
	
	var isNone: Bool {
		if case .none = self {
			return true
		}
		return false
	}
	
}

private var signalResendAction: SignalResendAction = .none

private let groupForSyncOfSignalResend = DispatchGroup()
private let semaphoreForSyncOfSignalResend = DispatchSemaphore(value: 1)

/* Must be out of SignalHandling struct because called by C */
private func threadForSignalResendMain(_ arg: UnsafeMutableRawPointer) -> UnsafeMutableRawPointer? {
	/* Set thread name. Can be useful for debug. We don’t care about failure. */
	_ = pthread_setname_np("com.xcode-actions.unsigactioned-signal-resend")
	
	var fullMask = Signal.fullSigset
	var emptyMask = Signal.emptySigset
	
	if pthread_sigmask(SIG_SETMASK, &fullMask, nil) != 0 {
		SignalHandlingConfig.logger?.error("Cannot set sigmask of thread for signal resend to full mask. The signal resending might dead-lock. Signal will still be received by your custom dispatch handler, but the original sigaction will not be delayed. This is highly improbable though.")
	}
	
	/* When we enter the thread, we let the caller know the thread has been
	 * started and is ready. */
	groupForSyncOfSignalResend.leave()
	
	repeat {
		/* Try and test possible race conditions. */
//		sleep(3)
		
		SignalHandlingConfig.logger?.trace("sigsuspend starting in thread for signal resend")
		/* We do want to use sigsuspend and not pause as we need all signals to be
		 * unblocked. */
		_ = sigsuspend(&emptyMask)
		SignalHandlingConfig.logger?.trace("sigsuspend returned in thread for signal resend")
		
		semaphoreForSyncOfSignalResend.wait()
		let action = signalResendAction
		signalResendAction = .none
		if pthread_sigmask(SIG_SETMASK, &fullMask, nil) != 0 {
			SignalHandlingConfig.logger?.error("Cannot set sigmask of thread for signal resend to full mask. The signal resending might not work sometimes. This is highly improbable though.")
		}
		semaphoreForSyncOfSignalResend.signal()
		
		switch action {
			case .none:
				SignalHandlingConfig.logger?.trace("Doing nothing after having received signal in thread for resend.")
				(/*nop*/)
				
			case .end:
				SignalHandlingConfig.logger?.trace("Ending thread after having received signal in thread for resend.")
				pthread_exit(nil) /* Or `return nil` (same) */
				
			case .reinstallSigactionAndLeaveGroup(let signal, let sigaction):
				SignalHandlingConfig.logger?.trace("Installing sigaction back to ignore from thread.")
				do    {try SignalHandling.installSigaction(signal: signal, action: sigaction)}
				catch {SignalHandlingConfig.logger?.error("Error installing sigaction back to ignore from thread.", metadata: ["signal": "\(signal)"])}
				groupForSyncOfSignalResend.leave()
		}
	} while true
}
