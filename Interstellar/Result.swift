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
    
    public var value: T? {
        switch self {
        case let .Success(v): return v.value
        case let .Error(error): return nil
        }
    }
}