/*:
 # Interstellar 2
 
 ## Observables

 An observable is the basic type of Interstellar. To create an observable simply initialize it with a value:
*/
let observable = Observable("User")
/*:
 Now you can add subscribers to this observable to get notified as soon as the value changes:
*/
observable.subscribe { value in
    print(value)
}

observable.update("World") // this will invoke your subscriber
//: You can also add map an observable via a function to retrieve a new observable:
let greeting = observable.map { name in return "Hello \(name)" }

greeting.subscribe { value in print(value) } // prints "Hello World" because Observable remembers it's last value
//: The same can also be achieved by passing a function reference:
func greet(name: String) -> String {
    return "Hello \(name)"
}
let greeting2 = observable.map(greet)
//: [Next: Asynchronous Transforms](@next)
