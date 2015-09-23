// Compatibility.swift
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

public extension Result {
    /**
    Transform a result into another result using a function. If the result was an error,
    the function will not be executed and the error returned instead.
    */
    @available(*, deprecated=1.0, message="Use flatMap instead.") public func bind<U>(f: T -> Result<U>) -> Result<U> {
        return flatMap(f)
    }
    
    /**
    Transform a result into another result using a function. If the result was an error,
    the function will not be executed and the error returned instead.
    */
    @available(*, deprecated=1.0, message="Use flatMap instead.") public func bind<U>(f: T throws -> U) -> Result<U> {
        return flatMap(f)
    }
    
    /**
    Transform a result into another result using a function. If the result was an error,
    the function will not be executed and the error returned instead.
    */
    @available(*, deprecated=1.0, message="Use flatMap instead.") public func bind<U>(f:(T, (Result<U>->Void))->Void) -> (Result<U>->Void)->Void {
        return flatMap(f)
    }
}

public extension Signal {
    @available(*, deprecated=1.0, message="Use flatMap instead.") public func bind<U>(f: T -> Result<U>) -> Signal<U> {
        return flatMap(f)
    }
    
    /**
    Transform the signal into another signal using a function.
    */
    @available(*, deprecated=1.0, message="Use flatMap instead.") public func bind<U>(f: T throws -> U) -> Signal<U> {
        return flatMap(f)
    }
    
    /**
    Transform the signal into another signal using a function.
    */
    @available(*, deprecated=1.0, message="Use flatMap instead.") public func bind<U>(f: (T, (Result<U>->Void))->Void) -> Signal<U> {
        return flatMap(f)
    }
}