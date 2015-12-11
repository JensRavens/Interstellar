//
//  Observable+Result.swift
//  Interstellar
//
//  Created by Jens Ravens on 11/12/15.
//  Copyright © 2015 nerdgeschoss GmbH. All rights reserved.
//

extension Observable where T : ResultType {
    func then<U>(transform: T.Value -> Result<U>) -> Observable<Result<U>> {
        return map { $0.result.flatMap(transform) }
    }
    
    func then<U>(transform: T.Value -> U) -> Observable<Result<U>> {
        return map { $0.result.map(transform) }
    }
    
    func then<U>(transform: T.Value throws -> U) -> Observable<Result<U>> {
        return map { $0.result.flatMap(transform) }
    }
    
    func next(block: T.Value -> Void) -> Observable<T> {
        subscribe { result in
            if let value = result.value {
                block(value)
            }
        }
        return self
    }
    
    func error(block: ErrorType -> Void) -> Observable<T> {
        subscribe { result in
            if let error = result.error {
                block(error)
            }
        }
        return self
    }
}
