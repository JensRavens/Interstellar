//: [Previous](@previous)

//: Handle errors in sequences of functions

import Foundation
import Interstellar

let text = Observable<String>()
func greetMaybe(subject: String) throws -> String {
    if subject.characters.count % 2 == 0 {
        return "Hello \(subject)"
    } else {
        throw NSError(domain: "Don't feel like greeting you.", code: 401, userInfo: nil)
    }
}
let content = text
    .map(greetMaybe)
    .then { text in
        print(text)
    }
    .error { error in
        print("There was a greeting error")
    }

text.update("World")

//: [Next](@next)
