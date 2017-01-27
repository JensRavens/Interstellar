//
//  InterstellarTests.swift
//  InterstellarTests
//
//  Created by Jens Ravens on 16/05/15.
//  Copyright (c) 2015 nerdgeschoss GmbH. All rights reserved.
//

import XCTest
import Interstellar

internal class Fail: Error, Equatable {
    public static func ==(lhs: Fail, rhs: Fail) -> Bool {
        return lhs.error == rhs.error
    }

    let error: String
    
    internal init(_ error: String) {
        self.error = error
    }
}

@available(*, deprecated: 2.0)
class SignalTests: XCTestCase {
    
    func greeter(_ subject: String) -> Result<String> {
        if subject.characters.count > 0 {
            return .success("Hello \(subject)")
        } else {
            return .error(Fail("No one to greet!"))
        }
    }
    
    func identity(_ a: String) -> Result<String> {
        return .success(a)
    }
    
    func asyncIdentity(_ a: String, completion: (Result<String>)->Void) {
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
        let expectation = self.expectation(description: "subscription not completed")
        signal.next { a in
            expectation.fulfill()
        }
        signal.update(Result(success:"Hello"))
        waitForExpectations(timeout: 0.2, handler: nil)
    }
    
    func testThrowingFunction() {
        func throwing(_ i: Int) throws -> Int {
            throw Fail("Error")
        }
        
        let transformed = Result(success: 1).flatMap(throwing)
        
        XCTAssertNil(transformed.value)
    }
    
    func testThrowingSignal() {
        func throwing(_ i: Int) throws -> Int {
            throw Fail("Error")
        }
        
        let signal = Signal<Int>()
        let expectation = self.expectation(description: "subscription not completed")
        
        signal.flatMap(throwing).error { _ in expectation.fulfill() }
        signal.update(.success(1))
        
        waitForExpectations(timeout: 0.2, handler: nil)
    }
}
