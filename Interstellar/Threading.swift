import Foundation

public func mainThread<T>(a: Result<T>, completion: Result<T>->Void) {
    dispatch_async(dispatch_get_main_queue()){
        completion(a)
    }
}

public func backgroundThread<T>(queue: dispatch_queue_t)(_ a: Result<T>, _ completion: Result<T>->Void) {
    dispatch_async(queue){
        completion(a)
    }
}

public func backgroundThread<T>(a: Result<T>, completion: Result<T>->Void) {
    let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
    backgroundThread(queue)(a, completion)
}