//: [Previous](@previous)

//: Creating and updating a signal

import Interstellar

let text = Signal<String>()

text.next { string in
    print("Hello \(string)")
}

text.update("World")

//: [Next](@next)
