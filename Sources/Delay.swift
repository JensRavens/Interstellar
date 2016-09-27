// Threading.swift
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

import Dispatch
import Foundation

@available(*, deprecated: 2.0)
public extension Signal {
    /**
        Creates a new signal that mirrors the original signal but is delayed by x seconds. If no queue is specified, the new signal will call it's observers and transforms on the main queue.
    */
    public func delay(_ seconds: TimeInterval, queue: DispatchQueue = DispatchQueue.main) -> Signal<T> {
        let signal = Signal<T>()
        subscribe { result in
            queue.asyncAfter(deadline: DispatchTime.now() + seconds) {
                signal.update(result)
            }
        }
        return signal
    }
}

public extension Observable {
    /**
     Creates a new observable that mirrors the original observable but is delayed by x seconds. If no queue is specified, the new observable will call it's observers and transforms on the main queue.
     */
    public func delay(_ seconds: TimeInterval, queue: DispatchQueue = DispatchQueue.main) -> Observable<T> {
        let observable = Observable<T>()
        subscribe { result in
            queue.asyncAfter(deadline: DispatchTime.now() + seconds) {
                observable.update(result)
            }
        }
        return observable
    }
}
