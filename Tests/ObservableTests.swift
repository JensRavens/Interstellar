//
//  ObservableTests.swift
//  Interstellar
//
//  Created by Jens Ravens on 11/04/16.
//  Copyright © 2016 nerdgeschoss GmbH. All rights reserved.
//

import XCTest
import Interstellar

class ObservableTests: XCTestCase {
    
    func greeter(_ subject: String) -> String {
        return "Hello \(subject)"
    }
    
    func greetLater(_ subject: String) -> Observable<String> {
        return Observable("Hello \(subject)")
    }
    
    func testMappingAnObservable() {
        let greeting = Observable("World").map(greeter)
        XCTAssertEqual(greeting.peek(), "Hello World")
    }
    
    func testFlatMappingObservable() {
        let greeting = Observable("World").flatMap(greetLater)
        XCTAssertEqual(greeting.peek(), "Hello World")
    }
    
    func testSubscription() {
        let observable = Observable<String>()
        let expectation = self.expectation(description: "subscription not completed")
        observable.subscribe { a in
            expectation.fulfill()
        }
        observable.update("Hello")
        waitForExpectations(timeout: 0.2, handler: nil)
    }
    
    func testOnceSubscription() {
        let observable = Observable<String>(options:[.Once])
        var count = 0
        observable.subscribe { a in
            count += 1
        }
        observable.update("Hello")
        observable.update("Hello")
        XCTAssertEqual(count, 1)
    }
    
    func testOnceSubscriptionAfterCompletion() {
        let observable = Observable<String>("Hello", options:[.Once])
        var count = 0
        observable.subscribe { a in
            count += 1
        }
        observable.update("Hello")
        XCTAssertEqual(count, 1)
    }
    
    func testLiveSubscriptions() {
        let observable = Observable<String>("Hello", options:[.NoInitialValue])
        XCTAssertNil(observable.peek())
        observable.update("Hello")
        XCTAssertNil(observable.peek())
    }
    
    func testUnsubscribe() {
        let observable = Observable<String>()
        var count = 0
        let token = observable.subscribe { a in
            count += 1
        }
        observable.update("Hello")
        observable.unsubscribe(token)
        observable.update("Hello")
        XCTAssertEqual(count, 1)
    }

    func testMergeInvocations() {
        let lhs = Observable<String>()
        let rhs = Observable<String>()
        var count = 0
        lhs.merge(rhs).subscribe { _, _ in
            count += 1
        }
        lhs.update("")
        XCTAssertEqual(count, 0)
        rhs.update("")
        XCTAssertEqual(count, 1)
    }

    func testMergeValues() {
        let lhs = Observable<String>()
        let rhs = Observable<String>()
        var first = "", second = ""
        lhs.merge(rhs).subscribe { lhs, rhs in
            first = lhs
            second = rhs
        }
        lhs.update("first")
        rhs.update("second")
        XCTAssertEqual(first, "first")
        XCTAssertEqual(second, "second")
    }
}
