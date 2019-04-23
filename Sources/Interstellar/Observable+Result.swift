//
//  Observable+Result.swift
//  Interstellar
//
//  Created by Jens Ravens on 11/12/15.
//  Copyright © 2015 nerdgeschoss GmbH. All rights reserved.
//

public protocol ResultType {
  associatedtype Success
  var _result: Result<Success,Error> {get}
}

extension Result: ResultType {
  public var _result: Result<Success, Error> {
    return self as! Result<Success, Error>
  }
}

public extension Observable where T : ResultType {
    /// Observables containing a Result<T> can be chained to only continue in the success case.
    func then<U>(_ transform: @escaping (T.Success) -> Result<U, Error>) -> Observable<Result<U, Error>> {
        return map { $0._result.flatMap(transform) }
    }
    
    /// Observables containing a Result<T> can be chained to only continue in the success case.
    func then<U>(_ transform: @escaping (T.Success) -> U) -> Observable<Result<U, Error>> {
        return map { $0._result.map(transform) }
    }
  
    /// Observables containing a Result<T> can be chained to only continue in the success case.
    func then<U>(_ transform: @escaping (T.Success) throws -> U) -> Observable<Result<U,Error>> {
      return map { $0._result.flatMap { value in Result { try transform(value) } }}
    }
    
    /// Observables containing a Result<T> can be chained to only continue in the success case.
    func then<U>(_ transform: @escaping (T.Success) -> Observable<U>) -> Observable<Result<U,Error>> {
        return flatMap { [options] in
            let observable = Observable<Result<U,Error>>(options: options)
            switch $0._result {
            case let .success(v): transform(v).subscribe { observable.update(.success($0)) }
            case let .failure(error): observable.update(.failure(error))
            }
            return observable
        }
    }
    
    /// Observables containing a Result<T> can be chained to only continue in the success case.
    func then<U>(_ transform: @escaping (T.Success) -> Observable<Result<U, Error>>) -> Observable<Result<U, Error>> {
        return flatMap { [options] in
            switch $0._result {
            case let .success(v): return transform(v)
            case let .failure(error): return Observable<Result<U, Error>>(Result.failure(error), options: options)
            }
        }
    }
    
    /// Only subscribe to successful events.
    @discardableResult func next(_ block: @escaping (T.Success) -> Void) -> Observable<T> {
        subscribe { result in
            if let value = try? result._result.get() {
                block(value)
            }
        }
        return self
    }
    
    /// Only subscribe to errors.
    @discardableResult func error(_ block: @escaping (Error) -> Void) -> Observable<T> {
        subscribe { result in
            if case let Result.failure(error) = result._result {
                block(error)
            }
        }
        return self
    }
    
    /// Peek at the value of the observable.
    func peek() -> T.Success? {
        return try? self.value?._result.get()
    }
}
