//: [Previous](@previous)

//: Creating and updating a signal

import Interstellar

let text = Observable<String>()

text.subscribe { string in
    print("Hello \(string)")
}

text.update("World")

//: [Next](@next)
