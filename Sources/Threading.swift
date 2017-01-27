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

/**
    Several functions that should make multithreading simpler.
    Use this functions together with Signal.ensure:
        Signal.ensure(Thread.main) // will create a new Signal on the main queue
*/
public final class Thread {
    /// Transform a signal to the main queue
    public static func main<T>(_ a: T, completion: @escaping (T)->Void) {
        queue(DispatchQueue.main)(a, completion)
    }

    /// Transform the signal to a specified queue
    public static func queue<T>(_ queue: DispatchQueue) -> (T, @escaping (T)->Void) -> Void {
        return { a, completion in
            queue.async{
                completion(a)
            }
        }
    }

    /// Transform the signal to a global background queue with priority default
    public static func background<T>(_ a: T, completion: @escaping (T)->Void) {
        DispatchQueue.global(qos: .background).async {
            completion(a)
        }
    }
}

public final class Queue {
    /// Transform an observable to the main queue
    public static func main<T>(_ a: T) -> Observable<T> {
        return queue(DispatchQueue.main)(a)
    }
    
    /// Transform the observalbe to a specified queue
    public static func queue<T>(_ queue: DispatchQueue) -> (T) -> Observable<T> {
        return { t in
            let observable = Observable<T>(options: [.Once])
            queue.async{
                observable.update(t)
            }
            return observable
        }
    }
    
    /// Transform the observable to a global background queue with priority default
    public static func background<T>(_ a: T) -> Observable<T> {
        let q = DispatchQueue.global(qos: .background)
        return queue(q)(a)
    }
}
