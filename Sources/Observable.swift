//
//  Observable.swift
//  Interstellar
//
//  Created by Jens Ravens on 10/12/15.
//  Copyright © 2015 nerdgeschoss GmbH. All rights reserved.
//

import Foundation

public struct ObservingOptions: OptionSet {
    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    
    public static let NoInitialValue = ObservingOptions(rawValue: 1)
    public static let Once = ObservingOptions(rawValue: 2)
}

public final class Observable<T> {
    fileprivate typealias Observer = (T)->Void
    fileprivate var observers = [ObserverToken: Observer]()
    public private(set) var value: T?
    public let options: ObservingOptions
    fileprivate let mutex = Mutex()
    
    public init(options: ObservingOptions = []) {
        self.options = options
    }
    
    public init(_ value: T, options: ObservingOptions = []) {
        self.options = options
        if !options.contains(.NoInitialValue){
            self.value = value
        }
    }
    
    public static func merge<U>(_ observables: [Observable<U>], options: ObservingOptions = []) -> Observable<[U]> {
        let merged = Observable<[U]>(options: options)
        let copies = observables.map { $0.map { return $0 } } // copy all observables via subscription to not retain the originals
        for observable in copies {
            precondition(!observable.options.contains(.NoInitialValue), "Event style observables do not support merging")
            observable.subscribe { value in
                let values = copies.flatMap { $0.value }
                if values.count == copies.count {
                    merged.update(values)
                }
            }
            
        }
        return merged
    }
    
    @discardableResult public func subscribe(_ observer: @escaping (T) -> Void) -> ObserverToken {
        var token: ObserverToken!
        mutex.lock {
            let newHashValue = (observers.keys.map({$0.hashValue}).max() ?? -1) + 1
            token = ObserverToken(hashValue: newHashValue)
            if !(options.contains(.Once) && value != nil) {
                observers[token] = observer
            }
            if let value = value , !options.contains(.NoInitialValue) {
                observer(value)
            }
        }
        return token
    }
    
    public func update(_ value: T) {
        mutex.lock {
            if !options.contains(.NoInitialValue) {
                self.value = value
            }
            for observe in observers.values {
                observe(value)
            }
            if options.contains(.Once) {
                observers.removeAll()
            }
        }
    }

    public func unsubscribe(_ token: ObserverToken) {
        mutex.lock {
            observers[token] = nil
        }
    }
}


extension Observable {
    public func map<U>(_ transform: @escaping (T) -> U) -> Observable<U> {
        let observable = Observable<U>(options: options)
        subscribe { observable.update(transform($0)) }
        return observable
    }
    
    public func map<U>(_ transform: @escaping (T) throws -> U) -> Observable<Result<U>> {
        let observable = Observable<Result<U>>(options: options)
        subscribe { value in
            observable.update(Result(block: { return try transform(value) }))
        }
        return observable
    }
    
    public func flatMap<U>(_ transform: @escaping (T)->Observable<U>) -> Observable<U> {
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
