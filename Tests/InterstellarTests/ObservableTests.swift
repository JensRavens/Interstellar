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
        XCTAssertEqual(greeting.value, "Hello World")
    }
    
    func testFlatMappingObservable() {
        let greeting = Observable("World").flatMap(greetLater)
        XCTAssertEqual(greeting.value, "Hello World")
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
        XCTAssertNil(observable.value)
        observable.update("Hello")
        XCTAssertNil(observable.value)
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
    
    func testTokenUnsubscribe() {
        let observable = Observable<String>()
        var count = 0
        let token = observable.subscribe { a in
            count += 1
        }
        observable.update("Hello")
        token.unsubscribe()
        observable.update("Hello")
        XCTAssertEqual(count, 1)
    }

    func testMergeInvocations() {
        let lhs = Observable<String>()
        let rhs = Observable<String>()
        var count = 0
        lhs.merge(rhs).subscribe { _ in
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
        lhs.merge(rhs).subscribe { arg in
            let (lhs, rhs) = arg
            first = lhs
            second = rhs
        }
        lhs.update("first")
        rhs.update("second")
        XCTAssertEqual(first, "first")
        XCTAssertEqual(second, "second")
    }
    
    func testMergingObservables() {
        let hello = Observable("Hello")
        let world = Observable<String>()
        var updateCalled = 0
        let greeting = Observable<[String]>.merge([hello, world])
        greeting.subscribe { _ in updateCalled += 1 }
        XCTAssertNil(greeting.value)
        XCTAssertEqual(updateCalled, 0)
        world.update("World")
        XCTAssertEqual(updateCalled, 1)
        XCTAssertEqual(greeting.value ?? [""], ["Hello", "World"])
    }

    func testFilterObservable() {
        let underTest = Observable<Int>()
        var results = [Int]()

        // Filter even numbers
        underTest.filter { $0 % 2 == 0 }.subscribe { results.append($0) }
        [1, 2, 3, 4, 5, 6].forEach { underTest.update($0) }

        XCTAssert(results == [2, 4, 6])
    }
}

#if os(Linux)
    extension ObservableTests {
        static var allTests : [(String, (ObservableTests) -> () throws -> Void)] {
            return [
                ("testMappingAnObservable", testMappingAnObservable),
                ("testFlatMappingObservable", testFlatMappingObservable),
                ("testSubscription", testSubscription),
                ("testLiveSubscriptions", testLiveSubscriptions),
                ("testOnceSubscription", testOnceSubscription),
                ("testOnceSubscriptionAfterCompletion", testOnceSubscriptionAfterCompletion),
                ("testMergeInvocations", testMergeInvocations),
                ("testMergeValues", testMergeValues),
                ("testMergingObservables", testMergingObservables),
                ("testFilterObservable", testFilterObservable)
            ]
        }
    }
#endif
