//: [Previous](@previous)
/*: 
 ## Asynchronous Transforms

 Imagine you have a function that returns with a callback later:
*/
func greetAsync(name: String, completion: (String)->Void) {
    completion("Hello \(name)")
}
//: Now you can return an Observable and subscribe instead:
func greet(name: String) -> Observable<String> {
    return Observable("Hello \(name)")
}
//: If you'd map an observable through this function, you'd get an Observable of an Observable:
let name = Observable("World")

let nestedGreeting: Observable<Observable<String>> = name.map(greet)
//: This is most probably not what your want. Use `flatMap` instead:
let greeting: Observable<String> = name.flatMap(greet)

greeting.subscribe { print($0) }

name.update("Jon Doe")

//: [Next: Error Handling](@next)
