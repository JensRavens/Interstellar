//
//  EventSubscription.swift
//
//  Created by Francescu Santoni on 12/02/2019.
//

import Foundation

public class EventSubscription<T> {
    public typealias HandlerType = (T) -> ()
    
    private var _valid: () -> Bool
    
    /// Handler to be caled when value changes.
    public private(set) var handler: HandlerType
    
    /// When invalid subscription is to be notified, it is removed instead.
    public func valid() -> Bool {
        if !_valid() {
            invalidate()
            return false
        } else {
            return true
        }
    }
    
    /// Marks the event for removal, frees the handler and owned objects
    public func invalidate() {
        _valid = { false }
        handler = { _ in () }
    }
    
    /// Init with a handler and an optional owner.
    /// If owner is present, valid() is tied to its lifetime.
    public init(owner o: AnyObject?, handler h: @escaping HandlerType) {
        if o == nil {
            _valid = { true }
        } else {
            _valid = { [weak o] in o != nil }
        }
        handler = h
    }

}
