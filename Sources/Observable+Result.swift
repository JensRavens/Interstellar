//
//  Observable+Result.swift
//  Interstellar
//
//  Created by Jens Ravens on 11/12/15.
//  Copyright © 2015 nerdgeschoss GmbH. All rights reserved.
//

public extension Observable where T : ResultType {
    /**
    Observables containing a Result<T> can be chained to only continue in the success case.
    */
    public func then<U>(_ transform: @escaping (T.Value) -> Result<U>) -> Observable<Result<U>> {
        return map { $0.result.flatMap(transform) }
    }
    
    public func then<U>(_ transform: @escaping (T.Value) -> U) -> Observable<Result<U>> {
        return map { $0.result.map(transform) }
    }
    
    public func then<U>(_ transform: @escaping (T.Value) throws -> U) -> Observable<Result<U>> {
        return map { $0.result.flatMap(transform) }
    }
    
    public func then<U>(_ transform: @escaping (T.Value) -> Observable<U>) -> Observable<Result<U>> {
        return flatMap { [options] in
            let observable = Observable<Result<U>>(options: options)
            switch $0.result {
            case let .success(v): transform(v).subscribe { observable.update(.success($0)) }
            case let .error(error): observable.update(.error(error))
            }
            return observable
        }
    }
    
    public func then<U>(_ transform: @escaping (T.Value) -> Observable<Result<U>>) -> Observable<Result<U>> {
        return flatMap { [options] in
            switch $0.result {
            case let .success(v): return transform(v)
            case let .error(error): return Observable<Result<U>>(Result.error(error), options: options)
            }
        }
    }
    
    @discardableResult public func next(_ block: @escaping (T.Value) -> Void) -> Observable<T> {
        subscribe { result in
            if let value = result.value {
                block(value)
            }
        }
        return self
    }
    
    @discardableResult public func error(_ block: @escaping (Error) -> Void) -> Observable<T> {
        subscribe { result in
            if let error = result.error {
                block(error)
            }
        }
        return self
    }
    
    public func peek() -> T.Value? {
        return self.value?.value
    }
}
