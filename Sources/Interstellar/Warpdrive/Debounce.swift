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

@available(*, deprecated: 2.0)
public extension Signal {
    /**
        Creates a new signal that is only firing once per specified time interval. The last 
        call to update will always be delivered (although it might be delayed up to the
        specified amount of seconds).
    */
    public func debounce(_ seconds: TimeInterval) -> Signal<T> {
        let signal = Signal<T>()
        var lastCalled: Date?
        
        subscribe { result in
            let currentTime = Date()
            func updateIfNeeded(_ signal: Signal<T>) -> (Result<T>) -> Void {
                return { result in
                    let timeSinceLastCall = lastCalled?.timeIntervalSinceNow
                    if timeSinceLastCall == nil || timeSinceLastCall! <= -seconds {
                        // no update before or update outside of debounce window
                        lastCalled = Date()
                        signal.update(result)
                    } else {
                        // skip result if there was a newer result
                        if currentTime.compare(lastCalled!) == .orderedDescending {
                            let s = Signal<T>()
                            s.delay(seconds - timeSinceLastCall!).subscribe(updateIfNeeded(signal))
                            s.update(result)
                        }
                    }
                }
            }
            updateIfNeeded(signal)(result)
        }
        
        return signal
    }
}

public extension Observable {
    /**
     Creates a new signal that is only firing once per specified time interval. The last
     call to update will always be delivered (although it might be delayed up to the
     specified amount of seconds).
     */
    public func debounce(_ seconds: TimeInterval) -> Observable<T> {
        let observable = Observable<T>()
        var lastCalled: Date?
        
        subscribe { value in
            let currentTime = Date()
            func updateIfNeeded(_ observable: Observable<T>) -> (T) -> Void {
                return { value in
                    let timeSinceLastCall = lastCalled?.timeIntervalSinceNow
                    if timeSinceLastCall == nil || timeSinceLastCall! <= -seconds {
                        // no update before or update outside of debounce window
                        lastCalled = Date()
                        observable.update(value)
                    } else {
                        // skip result if there was a newer result
                        if currentTime.compare(lastCalled!) == .orderedDescending {
                            let s = Observable<T>()
                            s.delay(seconds - timeSinceLastCall!).subscribe(updateIfNeeded(observable))
                            s.update(value)
                        }
                    }
                }
            }
            updateIfNeeded(observable)(value)
        }
        
        return observable
    }
}
