//
//  ResultTests.swift
//  Interstellar
//
//  Created by Jens Ravens on 04/12/15.
//  Copyright © 2015 nerdgeschoss GmbH. All rights reserved.
//

import XCTest
import Interstellar

class ResultTests: XCTestCase {
    
    func greeter(subject: String) -> Result<String> {
        if subject.characters.count > 0 {
            return .Success("Hello \(subject)")
        } else {
            let error: NSError = NSError(domain: "No one to greet!", code: 404, userInfo: nil)
            return .Error(error)
        }
    }
    
    func throwingGreeter(subject: String) throws -> String {
        return try greeter(subject).get()
    }
    
    func identity(a: String) -> String {
        return a
    }
    
    struct NastyError: ErrorType {}
    
    func testAccessingAValue() {
        let result = Result(success: "hello")
        XCTAssertEqual(result.value, "hello")
        XCTAssertNil(result.error)
    }
    
    func testAccessingAnError() {
        let error = NSError(domain: "", code: 0, userInfo: nil)
        let result = Result<String>(error: error)
        XCTAssertNil(result.value)
        XCTAssertEqual(result.error as? NSError, error)
    }
    
    func testThrowingAccessorReturns() {
        let result = Result(success: "hello")
        XCTAssertEqual(try! result.get(), "hello")
    }
    
    func testThrowingAccessorThrows() {
        let error = NSError(domain: "", code: 0, userInfo: nil)
        let result = Result<String>(error: error)
        do {
            try result.get()
            XCTFail()
        } catch let e {
            XCTAssertEqual(e as NSError, error)
        }
    }
    
    func testMappingAResult() {
        let result = Result(success: "Hello World").map(identity)
        XCTAssertEqual(result.value, "Hello World")
    }
    
    func testFlatMappingAResult() {
        let greeting = Result(success: "World").flatMap(greeter)
        XCTAssertEqual(greeting.value, "Hello World")
    }
    
    func testError() {
        let greeting = Result(success: "").flatMap(greeter)
        XCTAssertNil(greeting.value)
        XCTAssertNotNil(greeting.error)
    }
    
    func testThrowingFunction() {
        let result = Result(success: "World").flatMap(throwingGreeter)
        XCTAssertEqual(result.value, "Hello World")
    }
    
    func testNoEscape() {
        let result = Result(success: "World")
        let mapped = result.flatMap { string in
            return greeter(string)
        }
        XCTAssertEqual(mapped.value, "Hello World")
    }
    
    func testDefaultValue() {
        let a = Result(success: "Hello") ?? "Bonjour"
        XCTAssertEqual(a, "Hello")
        
        let b = Result<String>(error: NastyError()) ?? "Bonjour"
        XCTAssertEqual(b, "Bonjour")
    }
}
