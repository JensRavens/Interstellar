//
//  Observable+Result.swift
//  Interstellar
//
//  Created by Jens Ravens on 11/12/15.
//  Copyright © 2015 nerdgeschoss GmbH. All rights reserved.
//

public extension Observable where T : ResultType {
    public func then<U>(transform: T.Value -> Result<U>) -> Observable<Result<U>> {
        return map { $0.result.flatMap(transform) }
    }
    
    public func then<U>(transform: T.Value -> U) -> Observable<Result<U>> {
        return map { $0.result.map(transform) }
    }
    
    public func then<U>(transform: T.Value throws -> U) -> Observable<Result<U>> {
        return map { $0.result.flatMap(transform) }
    }
    
    public func next(block: T.Value -> Void) -> Observable<T> {
        subscribe { result in
            if let value = result.value {
                block(value)
            }
        }
        return self
    }
    
    public func error(block: ErrorType -> Void) -> Observable<T> {
        subscribe { result in
            if let error = result.error {
                block(error)
            }
        }
        return self
    }
    
    public func peekValue() -> T.Value? {
        return peek()?.value
    }
}
