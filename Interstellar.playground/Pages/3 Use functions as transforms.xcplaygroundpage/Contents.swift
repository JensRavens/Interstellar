//: [Previous](@previous)

//: Use functions as transforms

import Interstellar

let text = Observable<String>()
let greet: String->String = { subject in
    return "Hello \(subject)"
}
text
    .map(greet)
    .subscribe { text in
        print(text)
    }
text.update("World")

//: [Next](@next)
