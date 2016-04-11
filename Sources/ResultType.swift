//
//  ResultType.swift
//  Interstellar
//
//  Created by Jens Ravens on 10/12/15.
//  Copyright © 2015 nerdgeschoss GmbH. All rights reserved.
//

public protocol ResultType {
    associatedtype Value
    
    var error: ErrorType? { get }
    var value: Value? { get }
    
    var result: Result<Value> { get }
}

extension Result {
    public init(value: T?, error: ErrorType?) {
        if let error = error {
            self = Error(error)
        } else {
            self = Success(value!)
        }
    }
    
    public var result: Result<T> {
        return self
    }
}