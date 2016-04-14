//: [Previous](@previous)

//: Mapping and transforming signals

import Interstellar

let text = Observable<String>()

let greeting = text.map { subject in
    return "Hello \(subject)"
}

greeting.subscribe { text in
    print(text)
}

text.update("World")

//: [Next](@next)
