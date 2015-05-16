infix operator >>> { associativity left precedence 160 }

public func >>> <A,B> (left: Signal<A>, right: A->Result<B>) -> Signal<B> {
    return left.bind(right)
}

public func >>> <A,B>(left: Signal<A>, right: (A, (Result<B>->Void))->Void) -> Signal<B>{
    return left.bind(right)
}

public func >>> <A,B> (left: Signal<A>, right: A->B) -> Signal<B> {
    return left.map(right)
}

public func >>> <A,B,C>(left: A->Result<B>, right: B->Result<C>) -> A->Result<C> {
    return { a in
        left(a).bind(right)
    }
}

public func >>> <A,B,C>(left: (A, (Result<B>->Void))->Void, right: (B, (Result<C>->Void))->Void ) -> (A, (Result<C>->Void))->Void {
    return { a, completion in
        left(a){ result in
            switch(result) {
            case let .Success(box): right(box.value, completion)
            case let .Error(error): completion(.Error(error))
            }
        }
    }
}

public func >>> <A,B,C>(left: A->Result<B>, right: (B, (Result<C>->Void))->Void ) -> (A, (Result<C>->Void))->Void {
    return { a, completion in
        switch(left(a)) {
        case let .Success(box): right(box.value, completion)
        case let .Error(error): completion(.Error(error))
        }
    }
}

public func >>> <A,B,C>(left: (A, (Result<B>->Void))->Void, right: B->Result<C> ) -> (A, (Result<C>->Void))->Void {
    return { a, completion in
        left(a){ result in
            completion(result.bind(right))
        }
    }
}