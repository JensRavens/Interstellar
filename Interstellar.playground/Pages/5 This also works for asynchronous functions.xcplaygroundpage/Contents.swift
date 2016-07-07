//: [Previous](@previous)

//: This also works for asynchronous functions

import Foundation
import Interstellar

let text = Observable<String>()

func greetMaybe(subject: String) -> Observable<Result<String>> {
    if subject.characters.count % 2 == 0 {
        return Observable(.success("Hello \(subject)"))
    } else {
        let error = NSError(domain: "Don't feel like greeting you.", code: 401, userInfo: nil)
        return Observable(.error(error))
    }
}

text
    .flatMap(greetMaybe)
    .next { text in
        print(text)
    }
    .error { error in
        print("There was a greeting error")
    }

text.update("World")

//: [Next](@next)
