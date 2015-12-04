//: [Previous](@previous)

//: Use functions as transforms

import Interstellar

let text = Signal<String>()
let greet: String->String = { subject in
    return "Hello \(subject)"
}
text
    .map(greet)
    .next { text in
        print(text)
    }
text.update("World")

//: [Next](@next)
