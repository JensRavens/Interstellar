//
//  InterstellarTests.swift
//  InterstellarTests
//
//  Created by Jens Ravens on 16/05/15.
//  Copyright (c) 2015 nerdgeschoss GmbH. All rights reserved.
//

import XCTest
import Interstellar

class SignalTests: XCTestCase {

    func greeter(subject: String) -> Result<String> {
        if subject.characters.count > 0 {
            return .success("Hello \(subject)")
        } else {
            let error: NSError = NSError(domain: "No one to greet!", code: 404, userInfo: nil)
            return .error(error)
        }
    }

    func identity(_ a: String) -> Result<String> {
        return .success(a)
    }

    func asyncIdentity(a: String, completion: (Result<String>) -> Void) {
        completion(identity(a))
    }

    func testMappingASignal() {
        let greeting = Signal("World").map { subject in
            "Hello \(subject)"
        }
        XCTAssertEqual(greeting.peek(), "Hello World")
    }

    func testBindingASignal() {
        let greeting = Signal("World").flatMap(greeter).peek()
        XCTAssertEqual(greeting, "Hello World")
    }

    func testFlatMappingASignal() {
        let greeting = Signal("Hello").flatMap { greeting in
            Signal(greeting + " World")
        }.peek()
        XCTAssertEqual(greeting, "Hello World")
    }

    func testError() {
        let greeting = Signal("").flatMap(greeter).peek()
        XCTAssertNil(greeting)
    }

    func testSubscription() {
        let signal = Signal<String>()
        let promise = expectation(withDescription:"subscription not completed")
        signal.next { a in
            promise.fulfill()
        }
        signal.update(.success("Hello"))
        waitForExpectations(withTimeout:0.2, handler: nil)
    }

    func testThrowingFunction() {
        func throwing(i: Int) throws -> Int {
            throw NSError(domain: "Error", code: 404, userInfo: nil)
        }

        let transformed = Result(success: 1).flatMap(throwing)

        XCTAssertNil(transformed.value)
    }

    func testThrowingSignal() {
        func throwing(i: Int) throws -> Int {
            throw NSError(domain: "Error", code: 404, userInfo: nil)
        }

        let signal = Signal<Int>()
        let promise = expectation(withDescription: "subscription not completed")

        signal.flatMap(throwing).error { _ in promise.fulfill() }
        signal.update(.success(1))

        waitForExpectations(withTimeout: 0.2, handler: nil)
    }
}
