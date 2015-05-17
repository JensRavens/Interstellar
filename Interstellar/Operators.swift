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

public func >>> <A,B>(left: Signal<A>, right: (Result<A>, (Result<B>->Void))->Void) -> Signal<B>{
    return left.ensure(right)
}