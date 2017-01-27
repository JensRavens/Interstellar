//
//  ResultType.swift
//  Interstellar
//
//  Created by Jens Ravens on 10/12/15.
//  Copyright © 2015 nerdgeschoss GmbH. All rights reserved.
//

/// Conform to ResultType to use your own result type, e.g. from other libraries with Interstellar.
public protocol ResultType {
    /// Describes the contained successful type of this result.
    associatedtype Value
    
    /// Return an error if the result is unsuccessful, otherwise nil.
    var error: Error? { get }
    
    /// Return the value if the result is successful, otherwise nil.
    var value: Value? { get }
    
    /// Convert this result into an `Interstellar.Result`. This implementation is optional.
    var result: Result<Value> { get }
}

extension ResultType {
    public var result: Result<Value> {
        return Result(value: value, error: error)
    }
}

extension Result {
    public init(value: T?, error: Error?) {
        if let error = error {
            self = .error(error)
        } else {
            self = .success(value!)
        }
    }
    
    public init(block: (Void) throws -> T) {
        do {
            self = try .success(block())
        } catch let e {
            self = .error(e)
        }
    }
    
    public var result: Result<T> {
        return self
    }
}
