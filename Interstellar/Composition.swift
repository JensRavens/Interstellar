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

