// Signal.swift
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

/**
    A Signal is value that will or will not contain a value in the future (just
    like the concept of futures). In contrast to futures, the value of a signal
    can change at any time.

    Use next to subscribe to .Success updates, .error for .Error updates and 
    update to update the current value of the signal.

        let text = Signal<String>()

        text.next { string in
            println("Hello \(string)")
        }

        text.update(.success("World"))

*/

@available(*, deprecated: 2.0, message:"Use Observable<Result<T>> instead.")
public final class Signal<T> {
    
    fileprivate var value: Result<T>?
    fileprivate var callbacks: [(Result<T>) -> Void] = []
    fileprivate let mutex = Mutex()
    
    /// Automatically infer the type of the signal from the argument.
    public convenience init(_ value: T){
        self.init()
        self.value = .success(value)
    }
    
    public init() {

    }
    
    /**
        Transform the signal into another signal using a function.
    */
    public func map<U>(_ f: @escaping (T) -> U) -> Signal<U> {
        let signal = Signal<U>()
        subscribe { result in
            signal.update(result.map(f))
        }
        return signal
    }
    
    /**
        Transform the signal into another signal using a function.
    */
    public func flatMap<U>(_ f: @escaping (T) -> Result<U>) -> Signal<U> {
        let signal = Signal<U>()
        subscribe { result in
            signal.update(result.flatMap(f))
        }
        return signal
    }
    
    /**
        Transform the signal into another signal using a function.
    */
    public func flatMap<U>(_ f: @escaping (T) throws -> U) -> Signal<U> {
        let signal = Signal<U>()
        subscribe { result in
            signal.update(result.flatMap(f))
        }
        return signal
    }
    
    /**
        Transform the signal into another signal using a function.
    */
    public func flatMap<U>(_ f: @escaping (T, (@escaping(Result<U>)->Void))->Void) -> Signal<U> {
        let signal = Signal<U>()
        subscribe { result in
            result.flatMap(f)(signal.update)
        }
        return signal
    }
    
    /**
        Transform the signal into another signal using a function, return the
        value of the inner signal
    */
    public func flatMap<U>(_ f: @escaping ((T) -> Signal<U>)) -> Signal<U> {
        let signal = Signal<U>()
        subscribe { result in
            switch(result) {
            case let .success(value):
                let innerSignal = f(value)
                innerSignal.subscribe { innerResult in
                    signal.update(innerResult)
                }
            case let .error(error):
                signal.update(.error(error))
            }
        }
        return signal
    }
    
    /**
        Call a function with the result as an argument. Use this if the function should be
        executed no matter if the signal is a success or not.
        This method can also be used to convert an .Error into a .Success which might be handy
        for retry logic.
    */
    public func ensure<U>(_ f: @escaping (Result<T>, ((Result<U>)->Void))->Void) -> Signal<U> {
        let signal = Signal<U>()
        subscribe { result in
            f(result) { signal.update($0) }
        }
        return signal
    }
    
    /**
        Subscribe to the changes of this signal (.Error and .Success).
        This method is chainable.
    */
    @discardableResult public func subscribe(_ f: @escaping (Result<T>) -> Void) -> Signal<T> {
        if let value = value {
            f(value)
        }
        mutex.lock {
            callbacks.append(f)
        }
        return self
    }
    
    public func filter(_ f: @escaping (T) -> Bool) -> Signal<T>{
        let signal = Signal<T>()
        subscribe { result in
            switch(result) {
            case let .success(value):
                if f(value) {
                    signal.update(result)
                }
            case let .error(error): signal.update(.error(error))
            }
        }
        return signal
    }
    
    /**
        Subscribe to the changes of this signal (.Success only).
        This method is chainable.
    */
    @discardableResult public func next(_ g: @escaping (T) -> Void) -> Signal<T> {
        subscribe { result in
            switch(result) {
            case let .success(value): g(value)
            case .error(_): return
            }
        }
        return self
    }
    
    /**
        Subscribe to the changes of this signal (.Error only).
        This method is chainable.
    */
    @discardableResult public func error(_ g: @escaping (Error) -> Void) -> Signal<T> {
        subscribe { result in
            switch(result) {
            case .success(_): return
            case let .error(error): g(error)
            }
        }
        return self
    }
    
    /**
        Merge another signal into the current signal. This creates a signal that is
        a success if both source signals are a success. The value of the signal is a
        Tuple of the values of the contained signals.
    
            let signal = Signal("Hello").merge(Signal("World"))
            signal.value! == ("Hello", "World")
    
    */
    public func merge<U>(_ merge: Signal<U>) -> Signal<(T,U)> {
        let signal = Signal<(T,U)>()
        self.next { a in
            if let b = merge.peek() {
                signal.update(.success((a,b)))
            }
        }
        merge.next { b in
            if let a = self.peek() {
                signal.update(.success((a,b)))
            }
        }
        let errorHandler = { (error: Error) in
            signal.update(error)
        }
        self.error(errorHandler)
        merge.error(errorHandler)
        return signal
    }
    
    /**
        Update the content of the signal. This will notify all subscribers of this signal
        about the new value.
    */
    public func update(_ result: Result<T>) {
        mutex.lock {
            value = result
            callbacks.forEach{$0(result)}
        }
    }
    
    /**
        Update the content of the signal. This will notify all subscribers of this signal
        about the new value.
     */
    public func update(_ value: T) {
        update(.success(value))
    }
    
    /**
        Update the content of the signal. This will notify all subscribers of this signal
        about the new value.
     */
    public func update(_ error: Error) {
        update(.error(error))
    }
    
    /**
        Direct access to the content of the signal as an optional. If the result was a success,
        the optional will contain the value of the result.
    */
    public func peek() -> T? {
        return value?.value
    }
}

@available(*, deprecated: 2.0)
extension Signal {
    func observable() -> Observable<Result<T>> {
        let observable = Observable<Result<T>>()
        subscribe(observable.update)
        return observable
    }
}
