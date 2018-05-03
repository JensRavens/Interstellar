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
    
    func greeter(_ subject: String) -> Result<String> {
        if subject.count > 0 {
            return .success("Hello \(subject)")
        } else {
            return .error(Fail("No one to greet!"))
        }
    }
    
    func throwingGreeter(_ subject: String) throws -> String {
        return try greeter(subject).get()
    }
    
    func identity(_ a: String) -> String {
        return a
    }
    
    struct NastyError: Error {}
    
    func testAccessingAValue() {
        let result = Result(success: "hello")
        XCTAssertEqual(result.value, "hello")
        XCTAssertNil(result.error)
    }
    
    func testAccessingAnError() {
        let error = Fail("")
        let result = Result<String>(error: error)
        XCTAssertNil(result.value)
        XCTAssertEqual(result.error as? Fail, error)
    }
    
    func testThrowingAccessorReturns() {
        let result = Result(success: "hello")
        XCTAssertEqual(try! result.get(), "hello")
    }
    
    func testThrowingAccessorThrows() {
        let error = Fail("")
        let result = Result<String>(error: error)
        do {
            let _ = try result.get()
            XCTFail()
        } catch let e {
            XCTAssertEqual(e as! Fail, error)
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
