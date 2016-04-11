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
    
    func greeter(subject: String) -> String {
        return "Hello \(subject)"
    }
    
    func greetLater(subject: String) -> Observable<String> {
        return Observable("Hello \(subject)")
    }
    
    func testMappingAnObservable() {
        let greeting = Observable("World").map(greeter)
        XCTAssertEqual(greeting.peek(), "Hello World")
    }
    
    func testFlatMappingSignal() {
        let greeting = Observable("World").flatMap(greetLater)
        XCTAssertEqual(greeting.peek(), "Hello World")
    }
    
    func testSubscription() {
        let observable = Observable<String>()
        let expectation = expectationWithDescription("subscription not completed")
        observable.subscribe { a in
            expectation.fulfill()
        }
        observable.update("Hello")
        waitForExpectationsWithTimeout(0.2, handler: nil)
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
}
