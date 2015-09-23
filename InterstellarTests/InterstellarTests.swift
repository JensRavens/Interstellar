//
//  InterstellarTests.swift
//  InterstellarTests
//
//  Created by Jens Ravens on 16/05/15.
//  Copyright (c) 2015 nerdgeschoss GmbH. All rights reserved.
//

import XCTest
import Interstellar

class InterstellarTests: XCTestCase {
    
    func greeter(subject: String) -> Result<String> {
        if subject.characters.count > 0 {
            return .Success("Hello \(subject)")
        } else {
            let error: NSError = NSError(domain: "No one to greet!", code: 404, userInfo: nil)
            return .Error(error)
        }
    }
    
    func identity(a: String) -> Result<String> {
        return .Success(a)
    }
    
    func asyncIdentity(a: String, completion: Result<String>->Void) {
        completion(identity(a))
    }
    
    func testMappingASignal() {
        let greeting = Signal("World").map { subject in
            "Hello \(subject)"
        }
        XCTAssertEqual(greeting.peek()!, "Hello World")
    }
    
    func testBindingASignal() {
        let greeting = Signal("World").flatMap(greeter).peek()!
        XCTAssertEqual(greeting, "Hello World")
    }
    
    func testError() {
        let greeting = Signal("").flatMap(greeter).peek()
        XCTAssertNil(greeting)
    }
    
    func testSubscription() {
        let signal = Signal<String>()
        let expectation = expectationWithDescription("subscription not completed")
        signal.next { a in
            expectation.fulfill()
        }
        signal.update(Result.Success("Hello"))
        waitForExpectationsWithTimeout(0.2, handler: nil)
    }
    
    func testThrowingFunction() {
        func throwing(i: Int) throws -> Int {
            throw NSError(domain: "Error", code: 404, userInfo: nil)
        }
        
        let result = Result.Success(1)
        
        let transformed = result.flatMap(throwing)
        
        XCTAssertNil(transformed.value)
    }
    
    func testThrowingSignal() {
        func throwing(i: Int) throws -> Int {
            throw NSError(domain: "Error", code: 404, userInfo: nil)
        }
        
        let signal = Signal<Int>()
        let expectation = expectationWithDescription("subscription not completed")
        
        signal.flatMap(throwing).error { _ in expectation.fulfill() }
        signal.update(.Success(1))
        
        waitForExpectationsWithTimeout(0.2, handler: nil)
    }
}
