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

public final class Signal<T> {
    
    private var value: Result<T>?
    private var callbacks: [Result<T> -> Void] = []
    
    public convenience init(_ value: T){
        self.init()
        self.value = .Success(Box(value))
    }
    
    public init() {
        
    }
    
    public func map<U>(f: T -> U) -> Signal<U> {
        let signal = Signal<U>()
        subscribe { result in
            signal.update(result.map(f))
        }
        return signal
    }
    
    public func bind<U>(f: T -> Result<U>) -> Signal<U> {
        let signal = Signal<U>()
        subscribe { result in
            signal.update(result.bind(f))
        }
        return signal
    }
    
    public func bind<U>(f: (T, (Result<U>->Void))->Void) -> Signal<U> {
        let signal = Signal<U>()
        subscribe { value in
            value.bind(f)(signal.update)
        }
        return signal
    }
    
    public func ensure<U>(f: (Result<T>, (Result<U>->Void))->Void) -> Signal<U> {
        let signal = Signal<U>()
        subscribe { value in
            f(value) { signal.update($0) }
        }
        return signal
    }
    
    public func subscribe(f: Result<T> -> Void) -> Signal<T> {
        if let value = value {
            f(value)
        }
        callbacks.append(f)
        return self
    }
    
    public func filter(f: T -> Bool) -> Signal<T>{
        let signal = Signal<T>()
        subscribe { value in
            switch(value) {
            case let .Success(box):
                if f(box.value) {
                    signal.update(value)
                }
            case let .Error(error): signal.update(.Error(error))
            }
        }
        return signal
    }
    
    public func next(g: T -> Void) -> Signal<T> {
        subscribe { result in
            switch(result) {
            case let .Success(box): g(box.value)
            case .Error(_): return
            }
        }
        return self
    }
    
    public func error(g: NSError -> Void) -> Signal<T> {
        subscribe { result in
            switch(result) {
            case let .Success(_): return
            case let .Error(error): g(error)
            }
        }
        return self
    }
    
    public func merge<U>(merge: Signal<U>) -> Signal<(T,U)> {
        let signal = Signal<(T,U)>()
        self.next { a in
            if let b = merge.peek() {
                signal.update(.Success(Box((a,b))))
            }
        }
        merge.next { b in
            if let a = self.peek() {
                signal.update(.Success(Box((a,b))))
            }
        }
        let errorHandler = { (error: NSError) in
            signal.update(.Error(error))
        }
        self.error(errorHandler)
        merge.error(errorHandler)
        return signal
    }
    
    public func update(value: Result<T>) {
        self.value = value
        self.callbacks.map{$0(value)}
    }
    
    public func peek() -> T? {
        return value?.value
    }
}