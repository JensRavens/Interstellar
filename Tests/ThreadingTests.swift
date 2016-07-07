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


func mainTest(_ expectation: XCTestExpectation?) -> (Result<String>, (Result<String>) -> Void) -> Void {
  return { (r: Result<String>, completion: (Result<String>) -> Void) in
    XCTAssertTrue(Thread.isMainThread)
    expectation?.fulfill()
  }
}

class ThreadingTests: XCTestCase {
    func testShouldDispatchToMainQueue() {
      let promise = expectation(withDescription:"thread called")
        let queue = DispatchQueue.global()
        queue.async {
            let s = Signal<String>()
            let _ = s.ensure(Thread.main)
                     .ensure(mainTest(promise))
            s.update("hello")
        }
        waitForExpectations(withTimeout:0.1, handler: nil)
    }

    func testDispatchToSelectedQueue() {
        let promise = expectation(withDescription:"thread called")
        let s = Signal<String>()
        s.ensure(Thread.background)
        .subscribe { _ in
            XCTAssertFalse(Thread.isMainThread)
            promise.fulfill()
        }
        s.update("hello")
        waitForExpectations(withTimeout: 0.1, handler: nil)
    }

    func testObservable() {
        let observable = Observable<String>()
        let log: (String) -> Void = { print($0) }
        observable.flatMap(Queue.main).subscribe(log)

    }
}
