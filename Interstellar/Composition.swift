// Composition.swift
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

infix operator |> { associativity left precedence 160 }

//MARK: Synchronous Bind
public func |> <A,B,C>(left: A->Result<B>, right: B->Result<C>) -> A->Result<C> {
    return { a in
        left(a).bind(right)
    }
}

//MARK: Asynchronous Bind
public func |> <A,B,C>(left: (A, (Result<B>->Void))->Void, right: (B, (Result<C>->Void))->Void ) -> (A, (Result<C>->Void))->Void {
    return { a, completion in
        left(a){ result in
            switch(result) {
            case let .Success(box): right(box.value, completion)
            case let .Error(error): completion(.Error(error))
            }
        }
    }
}

public func |> <A,B,C>(left: A->Result<B>, right: (B, (Result<C>->Void))->Void ) -> (A, (Result<C>->Void))->Void {
    return { a, completion in
        switch(left(a)) {
        case let .Success(box): right(box.value, completion)
        case let .Error(error): completion(.Error(error))
        }
    }
}

public func |> <A,B,C>(left: (A, (Result<B>->Void))->Void, right: B->Result<C> ) -> (A, (Result<C>->Void))->Void {
    return { a, completion in
        left(a){ result in
            completion(result.bind(right))
        }
    }
}

//MARK: Synchronous Ensure
public func |> <A,B,C>(left: A->Result<B>, right: Result<B>->Result<C>) -> A->Result<C> {
    return { a in
        right(left(a))
    }
}

public func |> <A,B,C>(left: Result<A>->Result<B>, right: B->Result<C>) -> Result<A>->Result<C> {
    return { a in
        left(a).bind(right)
    }
}

public func |> <A,B,C>(left: A->B, right: B->C) -> A->C {
    return { a in
        right(left(a))
    }
}


//MARK: Async Ensure
public func |> <A,B,C>(left: A->Result<B>, right: (Result<B>, Result<C>->Void)->Void) -> (A, Result<C>->Void)->Void {
    return { a, completion in
        right(left(a), completion)
    }
}

public func |> <A,B,C>(left: Result<A>->Result<B>, right: (B, Result<C>->Void)->Void) -> (Result<A>, Result<C>->Void)->Void {
    return { a, completion in
        left(a).bind(right)(completion)
    }
}

public func |> <A,B,C>(left: (A, Result<B>->Void)->Void, right: (Result<B>, Result<C>->Void)->Void) -> (A, Result<C>->Void)->Void {
    return { a, completion in
        left(a) { right($0, completion) }
    }
}

public func |> <A,B,C>(left: (Result<A>, Result<B>->Void)->Void, right: (Result<B>, Result<C>->Void)->Void) -> (Result<A>, Result<C>->Void)->Void {
    return { a, completion in
        left(a) { right($0, completion) }
    }
}

