import Interstellar
import Foundation

//: [Previous](@previous)

//: ## Error Handling

//: Sometimes a function might return later with either a successfull value or some error. This is generally encoded in the `Result` type.

let successfullValue = Result(success: "Hello World")
let ohThereWasAnError = Result<String>(error: NSError(domain: "Something went wrong", code: 500, userInfo: nil))

//: An `Observable` can contain results just as normal values:

let resultOfExpensiveCalculation: Observable<Result<String>> = Observable(successfullValue)

//: You can subscribe to it just like to a normal `Observable`:

resultOfExpensiveCalculation.subscribe { result in
    switch result {
    case let .Error(error): print(error)
    case let .Success(value): print(value)
    }
}

//: In case you want to chain multiple transforms but only want to continue on the successful path, there's the `then` method:

func uppercase(input: String) -> String {
    return input.uppercaseString
}

let transformed: Observable<Result<String>> = resultOfExpensiveCalculation.then(uppercase)

//: This even works for throwing functions. In case of an error the error is returned:

func throwingUppercase(input: String) throws -> String {
    return input.uppercaseString
}

let transformedAgain = transformed.then(throwingUppercase)

//: This way you can build a chain of transformations. As soon as any of those transforms returns an error, all further steps are skipped and the subscribe callback will be called with an error.

//: If you're only interested in a successful chain you can directly subscribe to succesful values:

transformedAgain.next { myMessage in
    myMessage
}

//: Or just subscribe to the failing case:

transformedAgain.error { error in
    error
    print("There was an error: \(error)")
}
