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
        let expectation = expectationWithDescription("delay called")
        Signal("test").delay(0.1).subscribe { _ in
            XCTAssertTrue(NSThread.isMainThread())
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(0.2, handler: nil)
    }
    
    func testDispatchToSelectedQueue() {
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        let expectation = expectationWithDescription("delay called")
        let s = Signal<String>()
        s.delay(0.1, queue: queue)
            .subscribe { _ in
            XCTAssertFalse(NSThread.isMainThread())
            expectation.fulfill()
        }
        s.update("hello")
        waitForExpectationsWithTimeout(0.2, handler: nil)
    }
    
    func testDispatchAfterGivenTime() {
        // wait 0.2 seconds and check if action from 0.1 seconds already happened
        var value: String? = nil
        let expectation = expectationWithDescription("delay called")
        Signal("test").delay(0.2).subscribe { _ in
            XCTAssertEqual(value, "value")
            expectation.fulfill()
        }
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            value = "value"
        }
        waitForExpectationsWithTimeout(0.2, handler: nil)
    }
}
