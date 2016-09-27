//
//  WarpDriveTests.swift
//  WarpDriveTests
//
//  Created by Jens Ravens on 13/10/15.
//  Copyright © 2015 nerdgeschoss GmbH. All rights reserved.
//

import Foundation
import XCTest
import Interstellar
import Dispatch

@available(*, deprecated: 2.0)
class DelayTests: XCTestCase {
    func testShouldDispatchToMainQueue() {
        let expectation = self.expectation(description: "delay called")
        Signal("test").delay(0.1).subscribe { _ in
            XCTAssertTrue(Thread.isMainThread)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 0.2, handler: nil)
    }
    
    func testDispatchToSelectedQueue() {
        let queue = DispatchQueue.global(qos: .default)
        let expectation = self.expectation(description: "delay called")
        let s = Signal<String>()
        s.delay(0.1, queue: queue)
            .subscribe { _ in
            XCTAssertFalse(Thread.isMainThread)
            expectation.fulfill()
        }
        s.update("hello")
        waitForExpectations(timeout: 0.2, handler: nil)
    }
    
    func testDispatchAfterGivenTime() {
        // wait 0.2 seconds and check if action from 0.1 seconds already happened
        var value: String? = nil
        let expectation = self.expectation(description: "delay called")
        Signal("test").delay(0.2).subscribe { _ in
            XCTAssertEqual(value, "value")
            expectation.fulfill()
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            value = "value"
        }
        waitForExpectations(timeout: 0.2, handler: nil)
    }
}
