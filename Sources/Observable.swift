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
    
    public static let None = ObservingOptions(rawValue: 0)
    public static let InitialValue = ObservingOptions(rawValue: 1)
    public static let Once = ObservingOptions(rawValue: 2)
}

public final class Observable<T> {
    private var observers = [ObserverType<T>]()
    private var lastValue: T?
    public let options: ObservingOptions
    
    public init(options: ObservingOptions = []) {
        self.options = options
    }
    
    public init(value: T, options: ObservingOptions = [.InitialValue]) {
        self.options = options
        lastValue = value
    }
    
    public func subscribe(observer: ObserverType<T>) {
        sync {
            observers.append(observer)
            if let value = lastValue where options.contains(.InitialValue) {
                observer.observe(value)
            }
        }
    }
    
    public func unsubscribe(observer: ObserverType<T>) {
        sync {
            guard let index = observers.indexOf(observer) else { return }
            observers.removeAtIndex(index)
        }
    }
    
    public func update(value: T) {
        sync {
            if options.contains(.InitialValue) {
                lastValue = value
            }
            for observer in observers {
                observer.observe(value)
            }
            if options.contains(.Once) {
                observers.removeAll()
            }
        }
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
    func map<U>(transform: T->U) -> Observable<U> {
        let observable = Observable<U>(options: options)
        subscribe { observable.update(transform($0)) }
        return observable
    }
    
    func flatMap<U>(transform: T->Observable<U>) -> Observable<U> {
        let observable = Observable<U>(options: options)
        subscribe { transform($0).subscribe(observable.update) }
        return observable
    }
}