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

class DelayTests: XCTestCase {
    func testShouldDispatchToMainQueue() {
      let promise = expectation(description: "delay called")
        Signal("test").delay(0.1).subscribe { _ in
            XCTAssertTrue(Thread.isMainThread)
            promise.fulfill()
        }
        waitForExpectations(timeout: 0.2, handler: nil)
    }

    func testDispatchToSelectedQueue() {
        let queue = DispatchQueue.global()
        let promise = expectation(description: "delay called")
        let s = Signal<String>()
        s.delay(0.1, queue: queue)
            .subscribe { _ in
            XCTAssertFalse(Thread.isMainThread)
            promise.fulfill()
        }
        s.update("hello")
        waitForExpectations(timeout: 0.2, handler: nil)
    }

    func testDispatchAfterGivenTime() {
        // wait 0.2 seconds and check if action from 0.1 seconds already happened
        var value: String? = nil
        let promise = expectation(description: "delay called")
        Signal("test").delay(0.2).subscribe { _ in
            XCTAssertEqual(value, "value")
            promise.fulfill()
        }
        let delayTime = DispatchTime.now() + 0.1
        let queue = DispatchQueue.main
        queue.asyncAfter(deadline: delayTime) {
            value = "value"
        }
        waitForExpectations(timeout: 0.2, handler: nil)
    }
}
