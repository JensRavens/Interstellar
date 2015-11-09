![Interstellar](https://raw.githubusercontent.com/JensRavens/Interstellar/assets/header.jpg)

The simplest `Signal<T>` implementation for Functional Reactive Programming you will ever find.

> This library does not use the term FRP (Functional Reactive Programming) in the way it was
> defined by Conal Elliot, but as a paradigm that is both functional and reactive. Read more
> about the difference at [Why I cannot say FRP but I just did](https://medium.com/@andrestaltz/why-i-cannot-say-frp-but-i-just-did-d5ffaa23973b).

## Features

- [x] Lightweight, simple, cross plattform FRP
- [x] Multithreading with GCD becomes a breeze
- [x] Most of your methods will conform to the needed syntax anyway.
- [x] Swift 2 compability
- [x] Multithreading with GCD becomes a breeze via [WarpDrive](https://github.com/jensravens/warpdrive)

## Requirements

- iOS 7.0+ / Mac OS X 10.9+
- Xcode 7

---

## Usage

> For a full guide on how this implementation works the the series of blog posts about
> [Functional Reactive Programming in Swift](http://jensravens.de/series/functional-reactive-programming-in-swift/)
> or the talk at UIKonf 2015 [How to use Functional Reactive Programming without Black Magic](http://jensravens.de/uikonf-talk/).

### Creating and updating a signal

```swift
let text = Signal<String>()

text.next { string in
    println("Hello \(string)")
}

text.update(.Success("World"))
```

### Mapping and transforming signals

```swift
let text = Signal<String>()

let greeting = text.map { subject in
    return "Hello \(subject)"
}

greeting.next { text in
    println(text)
}

text.update(.Success("World"))
```

### Use functions as transforms

```swift
let text = Signal<String>()
let greet: String->String = { subject in
    return "Hello \(subject)"
}
text.map(greet).next { text in
    println(text)
}
text.update(.Success("World"))
```

### Handle errors in sequences of functions

```swift
let text = Signal<String>()
func greetMaybe(subject: String)->Result<String> {
    if count(subject) % 2 == 0 {
        return .Success(Box("Hello \(subject)"))
    } else {
        let error = NSError(domain: "Don't feel like greeting you.", code: 401, userInfo: nil)
        return .Error(error)
    }
}
text.flatMap(greetMaybe)
.next { text in
    println(text)
}
.error { error in
    println("There was a greeting error")
}
text.update(.Success("World"))
```

### This also works for asynchronous functions

```swift
let text = Signal<String>()
func greetMaybe(subject: String, completion: Result<String>->Void) {
    if count(subject) % 2 == 0 {
        completion(.Success(Box("Hello \(subject)")))
    } else {
        let error = NSError(domain: "Don't feel like greeting you.", code: 401, userInfo: nil)
        completion(.Error(error))
    }
}
text.flatMap(greetMaybe)
.next { text in
    println(text)
}
.error { error in
    println("There was a greeting error")
}
text.update(.Success("World"))
```

---

## Communication

- If you **found a bug**, open an issue.
- If you **have a feature request**, open an issue.
- If you **want to contribute**, submit a pull request.

## Installation

> **Dynamic frameworks on iOS require a minimum deployment target of iOS 8 or later.**
>
> To use Interstellar with a project targeting iOS 7, you must include all Swift files directly in your project.

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects.

CocoaPods 0.36 adds supports for Swift and embedded frameworks. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate Interstellar into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

pod 'Interstellar'
```

Then, run the following command:

```bash
$ pod install
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that automates the process of adding frameworks to your Cocoa application.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate Interstellar into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "JensRavens/Interstellar" "swift2"
```

---

## FAQ

### Why use Interstellar instead of [insert your favorite FRP framework here]?

Interstellar is meant to be lightweight. There are no UIKit bindings, no heavy constructs - just a simple `Signal<T>`. Therefore it's easy to understand and portable (there is no dependency except Foundation).

* * *

## Credits

Interstellar is owned and maintained by [Jens Ravens](http://jensravens.de).

## Changelog

- *1.1* added compability with Swift 2. Also renamed bind to flatMap to be consistent with `Optional` and `Array`.
- *1.2* `Thread` was moved to a new project called [WarpDrive](https://github.com/jensravens/warpdrive)
- *1.3* WarpDrive has been merged into Interstellar. Also Interstellar is now divided into subspecs via cocoapods to make it easy to just select the needed components. The basic signal library is now "Interstellar/Core".

## License

Interstellar is released under the MIT license. See LICENSE for details.
