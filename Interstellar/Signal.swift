public final class Signal<T> {
    
    private var value: Result<T>?
    private var callbacks: [Result<T> -> Void] = []
    
    public convenience init(_ value: T){
        self.init()
        self.value = .Success(Box(value))
    }
    
    public init() {
        
    }
    
    public func map<U>(f: T -> U) -> Signal<U> {
        let signal = Signal<U>()
        subscribe { result in
            switch(result) {
            case let .Success(box): signal.update(result.map(f))
            case let .Error(error): signal.update(.Error(error))
            }
        }
        return signal
    }
    
    public func bind<U>(f: T -> Result<U>) -> Signal<U> {
        let signal = Signal<U>()
        subscribe { result in
            switch(result) {
            case let .Success(box): signal.update(f(box.value))
            case let .Error(error): signal.update(.Error(error))
            }
        }
        return signal
    }
    
    public func bind<U>(f: (T, (Result<U>->Void))->Void) -> Signal<U> {
        let signal = Signal<U>()
        subscribe { value in
            switch(value) {
            case let .Success(box):
                let value = box.value
                f(value){ result in
                    signal.update(result)
                }
            case let .Error(error): signal.update(.Error(error))
            }
        }
        return signal
    }
    
    public func subscribe(f: Result<T> -> Void) {
        if let value = value {
            f(value)
        }
        callbacks.append(f)
    }
    
    public func filter(f: T -> Bool) -> Signal<T>{
        let signal = Signal<T>()
        subscribe { value in
            switch(value) {
            case let .Success(box):
                if f(box.value) {
                    signal.update(value)
                }
            case let .Error(error): signal.update(.Error(error))
            }
        }
        return signal
    }
    
    public func next(g: T -> Void) {
        subscribe { result in
            switch(result) {
            case let .Success(box): g(box.value)
            case .Error(_): return
            }
        }
    }
    
    public func error(g: NSError -> Void) {
        subscribe { result in
            switch(result) {
            case let .Success(_): return
            case let .Error(error): g(error)
            }
        }
    }
    
    public func merge<U>(merge: Signal<U>) -> Signal<(T,U)> {
        let signal = Signal<(T,U)>()
        self.next { a in
            if let b = merge.peek() {
                signal.update(.Success(Box((a,b))))
            }
        }
        merge.next { b in
            if let a = self.peek() {
                signal.update(.Success(Box((a,b))))
            }
        }
        let errorHandler = { (error: NSError) in
            signal.update(.Error(error))
        }
        self.error(errorHandler)
        merge.error(errorHandler)
        return signal
    }
    
    public func update(value: Result<T>) {
        self.value = value
        self.callbacks.map{$0(value)}
    }
    
    public func peek() -> T? {
        return value?.value
    }
}