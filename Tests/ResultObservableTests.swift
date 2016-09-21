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
    
    var world: Observable<Result<String>> {
        return Observable(Result(success: "World"))
    }
    
    var nothing: Observable<Result<String>> {
        return Observable(Result(success: ""))
    }
    
    func testContinuingTheChain() {
        let greeting = world.then(greeter).then(throwingGreeter)
        XCTAssertEqual(greeting.peekValue(), "Hello Hello World")
    }
    
    func testError() {
        let greeting = nothing.then(throwingGreeter).peekValue()
        XCTAssertNil(greeting)
    }
}
