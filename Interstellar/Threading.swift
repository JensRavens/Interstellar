import Foundation

public final class Thread {
    public static func main<T>(a: Result<T>, completion: Result<T>->Void) {
        dispatch_async(dispatch_get_main_queue()){
            completion(a)
        }
    }
    
    public static func background<T>(queue: dispatch_queue_t)(_ a: Result<T>, _ completion: Result<T>->Void) {
        dispatch_async(queue){
            completion(a)
        }
    }
    
    public static func background<T>(a: Result<T>, completion: Result<T>->Void) {
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        background(queue)(a, completion)
    }
}