public enum Result<T> {
    case Success(Box<T>)
    case Error(NSError)
    
    public func map<U>(f: T -> U) -> Result<U> {
        switch self {
        case let .Success(v): return .Success(Box(f(v.value)))
        case let .Error(error): return .Error(error)
        }
    }
    
    public func bind<U>(f: T -> Result<U>) -> Result<U> {
        switch self {
        case let .Success(v): return f(v.value)
        case let .Error(error): return .Error(error)
        }
    }
    
    public func bind<U>(f:(T, (Result<U>->Void))->Void) -> (Result<U>->Void)->Void {
        return { g in
            switch self {
            case let .Success(v): f(v.value, g)
            case let .Error(error): g(.Error(error))
            }
        }
    }
    
    public func ensure<U>(f: Result<T> -> Result<U>) -> Result<U> {
        return f(self)
    }
    
    public func ensure<U>(f:(Result<T>, (Result<U>->Void))->Void) -> (Result<U>->Void)->Void {
        return { g in
            f(self, g)
        }
    }
    
    public var value: T? {
        switch self {
        case let .Success(v): return v.value
        case let .Error(error): return nil
        }
    }
}