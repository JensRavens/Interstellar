// Debounce.swift
//
// Copyright (c) 2015 Jens Ravens (http://jensravens.de)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

private var SignalUpdateCalledHandle: UInt8 = 0
public extension Signal {
    internal var lastCalled: NSDate? {
        get {
            if let handle = objc_getAssociatedObject(self, &SignalUpdateCalledHandle) as? NSDate {
                return handle
            } else {
                return nil
            }
        }
        set {
            objc_setAssociatedObject(self, &SignalUpdateCalledHandle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public func debounce(seconds: NSTimeInterval) -> Signal<T> {
        let signal = Signal<T>()
        
        subscribe { result in
            let currentTime = NSDate()
            func updateIfNeeded(signal: Signal<T>)(result: Result<T>) {
                let timeSinceLastCall = signal.lastCalled?.timeIntervalSinceNow
                if timeSinceLastCall == nil || timeSinceLastCall <= -seconds {
                    // no update before or update outside of debounce window
                    signal.lastCalled = NSDate()
                    signal.update(result)
                } else {
                    // skip result if there was a newer result
                    if currentTime.compare(signal.lastCalled!) == .OrderedDescending {
                        let s = Signal<T>()
                        s.delay(seconds - timeSinceLastCall!).subscribe(updateIfNeeded(signal))
                        s.update(result)
                    }
                }
            }
            updateIfNeeded(signal)(result:result)
        }
        
        return signal
    }
}