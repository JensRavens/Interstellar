// Result.swift
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
    A result contains the result of a computation or task. It might be either successfull
    with an attached value or a failure with an attached error (which conforms to Swift 2's
    ErrorType). You can read more about the implementation in
    [this blog post](http://jensravens.de/a-swifter-way-of-handling-errors/).
*/
public enum Result<T>: ResultType {
    case success(T)
    case error(Error)
    
    /**
        Initialize a result containing a successful value.
    */
    public init(success value: T) {
        self = Result.success(value)
    }
    
    /**
        Initialize a result containing an error
    */
    public init(error: Error) {
        self = .error(error)
    }
    
    /**
        Transform a result into another result using a function. If the result was an error,
        the function will not be executed and the error returned instead.
    */
    public func map<U>(_ f: @escaping (T) -> U) -> Result<U> {
        switch self {
        case let .success(v): return .success(f(v))
        case let .error(error): return .error(error)
        }
    }
    
    /**
        Transform a result into another result using a function. If the result was an error,
        the function will not be executed and the error returned instead.
    */
    public func flatMap<U>(_ f: (T) -> Result<U>) -> Result<U> {
        switch self {
        case let .success(v): return f(v)
        case let .error(error): return .error(error)
        }
    }
    
    /**
        Transform a result into another result using a function. If the result was an error,
        the function will not be executed and the error returned instead.
    */
    public func flatMap<U>(_ f: (T) throws -> U) -> Result<U> {
        return flatMap { t in
            do {
                return .success(try f(t))
            } catch let error {
                return .error(error)
            }
        }
    }
    /**
        Transform a result into another result using a function. If the result was an error,
        the function will not be executed and the error returned instead.
    */
    public func flatMap<U>(_ f:@escaping (T, (@escaping(Result<U>)->Void))->Void) -> (@escaping(Result<U>)->Void)->Void {
        return { g in
            switch self {
            case let .success(v): f(v, g)
            case let .error(error): g(.error(error))
            }
        }
    }
    
    /** 
        Call a function with the result as an argument. Use this if the function should be
        executed no matter if the result was a success or not.
    */
    public func ensure<U>(_ f: (Result<T>) -> Result<U>) -> Result<U> {
        return f(self)
    }
    
    /**
        Call a function with the result as an argument. Use this if the function should be
        executed no matter if the result was a success or not.
    */
    public func ensure<U>(_ f:@escaping (Result<T>, ((Result<U>)->Void))->Void) -> ((Result<U>)->Void)->Void {
        return { g in
            f(self, g)
        }
    }
    
    /**
        Direct access to the content of the result as an optional. If the result was a success,
        the optional will contain the value of the result.
    */
    public var value: T? {
        switch self {
        case let .success(v): return v
        case .error(_): return nil
        }
    }
    
    /**
        Direct access to the error of the result as an optional. If the result was an error,
        the optional will contain the error of the result.
    */
    public var error: Error? {
        switch self {
        case .success: return nil
        case .error(let x): return x
        }
    }
    
    /**
        Access the value of this result. If the result contains an error, that error is thrown.
    */
    public func get() throws -> T {
        switch self {
        case let .success(value): return value
        case .error(let error): throw error
        }
    }
}


/**
    Provide a default value for failed results.
*/
public func ?? <T> (result: Result<T>, defaultValue: @autoclosure () -> T) -> T {
    switch result {
    case .success(let x): return x
    case .error: return defaultValue()
    }
}
