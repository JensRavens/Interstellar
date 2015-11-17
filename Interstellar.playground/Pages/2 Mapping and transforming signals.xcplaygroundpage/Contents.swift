//: [Previous](@previous)

//: Mapping and transforming signals

import Interstellar

let text = Signal<String>()

let greeting = text.map { subject in
    return "Hello \(subject)"
}

greeting.next { text in
    print(text)
}

text.update(.Success("World"))

//: [Next](@next)