//
//  Observer.swift
//  Interstellar
//
//  Created by Jens Ravens on 10/12/15.
//  Copyright © 2015 nerdgeschoss GmbH. All rights reserved.
//

public class ObserverType<Element>: Equatable {
    public func observe(value: Element) {}
}

public func ==<T>(lhs: ObserverType<T>, rhs: ObserverType<T>) -> Bool {
    return lhs === rhs
}

public class BlockObserver<Element>: ObserverType<Element> {
    
    private let block: Element -> Void
    
    public init(block: Element -> Void) {
        self.block = block
    }
    
    override public func observe(value: Element) {
        block(value)
    }
}

extension Observable {
    public func subscribe(block: T->Void) {
        subscribe(BlockObserver(block: block))
    }
}