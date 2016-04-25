//
//  Observable.swift
//  Interstellar
//
//  Created by Jens Ravens on 10/12/15.
//  Copyright © 2015 nerdgeschoss GmbH. All rights reserved.
//

import Foundation

public struct ObservingOptions: OptionSetType {
    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    
    public static let NoInitialValue = ObservingOptions(rawValue: 1)
    public static let Once = ObservingOptions(rawValue: 2)
}

public final class Observable<T> {
    private typealias Observer = T->Void
    private var observers = [Int:Observer]()
    private var lastValue: T?
    public let options: ObservingOptions
    private let mutex = Mutex()
    
    public init(options: ObservingOptions = []) {
        self.options = options
    }
    
    public init(_ value: T, options: ObservingOptions = []) {
        self.options = options
        if !options.contains(.NoInitialValue){
            lastValue = value
        }
    }
    
    public func subscribe(observer: T -> Void) -> ObserverToken {
        var token: ObserverToken!
        mutex.lock {
            token = nextToken()
            if !(options.contains(.Once) && lastValue != nil) {
                observers[token.hash()] = observer
            }
            if let value = lastValue where !options.contains(.NoInitialValue) {
                observer(value)
            }
        }
        return token
    }
    
    public func unsubscribe(token: ObserverToken) {
        mutex.lock {
            observers[token.hash()] = nil
        }
    }
    
    public func update(value: T) {
        mutex.lock {
            if !options.contains(.NoInitialValue) {
                lastValue = value
            }
            for observe in observers.values {
                observe(value)
            }
            if options.contains(.Once) {
                observers.removeAll()
            }
        }
    }
    
    public func peek() -> T? {
        return lastValue
    }
    
    private func nextToken() -> ObserverToken {
        return (observers.keys.maxElement() ?? -1) + 1
    }
}

public protocol ObserverToken {
    func hash() -> Int
}

extension Int: ObserverToken {
    public func hash() -> Int {
        return self
    }
}

extension Observable {
    public func map<U>(transform: T -> U) -> Observable<U> {
        let observable = Observable<U>(options: options)
        subscribe { observable.update(transform($0)) }
        return observable
    }
    
    public func map<U>(transform: T throws -> U) -> Observable<Result<U>> {
        let observable = Observable<Result<U>>(options: options)
        subscribe { value in
            observable.update(Result(block: { return try transform(value) }))
        }
        return observable
    }
    
    public func flatMap<U>(transform: T->Observable<U>) -> Observable<U> {
        let observable = Observable<U>(options: options)
        subscribe { transform($0).subscribe(observable.update) }
        return observable
    }

    public func merge<U>(merge: Observable<U>) -> Observable<(T,U)> {
        let signal = Observable<(T,U)>()
        self.subscribe { a in
            if let b = merge.peek() {
                signal.update((a,b))
            }
        }
        merge.subscribe { b in
            if let a = self.peek() {
                signal.update((a,b))
            }
        }

        return signal
    }
}
