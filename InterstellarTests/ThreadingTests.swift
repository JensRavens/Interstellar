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

func mainTest(expectation: XCTestExpectation?)(r: Result<String>, completion:(Result<String>->Void)) {
    XCTAssertTrue(NSThread.isMainThread())
    expectation?.fulfill()
}

class ThreadingTests: XCTestCase {
    func testShouldDispatchToMainQueue() {
        let expectation = expectationWithDescription("thread called")
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        dispatch_async(queue) {
            let s = Signal<String>()
            s.ensure(Thread.main)
                .ensure(mainTest(expectation))
            s.update("hello")
        }
        waitForExpectationsWithTimeout(0.1, handler: nil)
    }
    
    func testDispatchToSelectedQueue() {
        let expectation = expectationWithDescription("thread called")
        let s = Signal<String>()
        s.ensure(Thread.background)
        .subscribe { _ in
            XCTAssertFalse(NSThread.isMainThread())
            expectation.fulfill()
        }
        s.update("hello")
        waitForExpectationsWithTimeout(0.1, handler: nil)
    }
}
