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
        sync {
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
        sync {
            observers[token.hash()] = nil
        }
    }
    
    public func update(value: T) {
        sync {
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

private extension Observable {
    private func sync(@noescape block: Void->Void) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        block()
    }
}

extension Observable {
    public func map<U>(transform: T->U) -> Observable<U> {
        let observable = Observable<U>(options: options)
        subscribe { observable.update(transform($0)) }
        return observable
    }
    
    public func flatMap<U>(transform: T->Observable<U>) -> Observable<U> {
        let observable = Observable<U>(options: options)
        subscribe { transform($0).subscribe(observable.update) }
        return observable
    }
}
