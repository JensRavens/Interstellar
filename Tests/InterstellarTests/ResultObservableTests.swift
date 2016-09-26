//
//  ObservableTests.swift
//  Interstellar
//
//  Created by Jens Ravens on 11/04/16.
//  Copyright © 2016 nerdgeschoss GmbH. All rights reserved.
//

import XCTest
import Interstellar

class ResultObservableTests: XCTestCase {
    
    func greeter(_ subject: String) -> String {
        return "Hello \(subject)"
    }
    
    func throwingGreeter(_ subject: String) throws -> String {
        if subject.characters.count > 0 {
            return "Hello \(subject)"
        } else {
            throw NSError(domain: "No one to greet!", code: 404, userInfo: nil)
        }
    }
    
    func asyncGreeter(_ subject: String) -> Observable<String> {
        return Observable("Hello \(subject)")
    }
    
    func asyncFail(_ subject: String) -> Observable<Result<String>> {
        return Observable(.error(NSError(domain: "Fail", code: 500, userInfo: nil)))
    }
    
    func neverCallMe(_ subject: String) -> Observable<Result<String>> {
        XCTFail()
        return Observable()
    }
    
    var world: Observable<Result<String>> {
        return Observable(Result(success: "World"))
    }
    
    var nothing: Observable<Result<String>> {
        return Observable(Result(success: ""))
    }
    
    func testContinuingTheChain() {
        let greeting = world.then(greeter).then(throwingGreeter)
        XCTAssertEqual(greeting.peek(), "Hello Hello World")
    }
    
    func testError() {
        let greeting = nothing.then(throwingGreeter).peek()
        XCTAssertNil(greeting)
    }
    
    func testAsyncChain() {
        let greeting = world.then(asyncGreeter)
        XCTAssertEqual(greeting.peek()!, "Hello World")
    }
    
    func testAsyncFail() {
        let greeting = world.then(asyncFail).then(neverCallMe)
        var error: Error?
        greeting.error { error = $0 }
        XCTAssertNil(greeting.peek())
        XCTAssertNotNil(error)
    }
}
