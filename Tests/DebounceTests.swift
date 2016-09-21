//
//  WarpDriveTests.swift
//  WarpDriveTests
//
//  Created by Jens Ravens on 13/10/15.
//  Copyright © 2015 nerdgeschoss GmbH. All rights reserved.
//

import Foundation
import XCTest
@testable import Interstellar

class DebounceTests: XCTestCase {

    func testDebounceImmediateley() {
        var string: String? = nil
        let s = Signal<String>()
        s.debounce(0).next { string = $0 }
        s.update("Hello")
        XCTAssertEqual(string, "Hello")
    }
    
    func testDebounceImmediatelyIfFirst () {
        var string: String? = nil
        let s = Signal<String>()
        s.debounce(5).next { string = $0 }
        s.update("Hello")
        XCTAssertEqual(string, "Hello")
    }
    
    func testDebounce() {
        var string: String? = nil
        var called = 0
        let signal = Signal<String>()
        let expectation = self.expectation(description: "Wait for debounce")
        
        signal.debounce(0.5).next { called += 1; string = $0 }
        signal.update("Hello")
        signal.update("World")
        
        Signal(0).delay(1).next { _ in
            XCTAssertEqual(called, 2)
            XCTAssertEqual(string, "World")
            expectation.fulfill()
        }
        
        XCTAssertEqual(called, 1)
        XCTAssertEqual(string, "Hello")
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testDebounceObservable() {
        var string: String? = nil
        var called = 0
        let observable = Observable<String>()
        let expectation = self.expectation(description: "Wait for debounce")
        
        observable.debounce(0.5).subscribe { called += 1; string = $0 }
        observable.update("Hello")
        observable.update("World")
        
        Signal(1).delay(1).next { _ in
            XCTAssertEqual(called, 2)
            XCTAssertEqual(string, "World")
            expectation.fulfill()
        }
        
        XCTAssertEqual(called, 1)
        XCTAssertEqual(string, "Hello")
        waitForExpectations(timeout: 2, handler: nil)
    }
    
}
