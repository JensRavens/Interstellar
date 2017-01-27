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

fileprivate func asyncOperation(value: String, completion: (Result<String>)->Void) {
    completion(Result<String>.success(value))
}

fileprivate func longOperation(value: String, completion: @escaping (Result<String>)->Void) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 10){
        completion(Result<String>.success(value))
    }
}

fileprivate func fail<T>(_ t: T) throws -> T {
    throw NSError(domain: "Error", code: 400, userInfo: nil)
}

@available(*, deprecated: 2.0)
class WaitingTests: XCTestCase {
    func testWaitingForSuccess() {
        let greeting = try! Signal("hello")
            .flatMap(asyncOperation)
            .wait()
        XCTAssertEqual(greeting, "hello")
    }
    
    func testWithinTimeoutForSuccess() {
        let greeting = try! Signal("hello")
            .flatMap(asyncOperation)
            .wait(0.3)
        XCTAssertEqual(greeting, "hello")
    }
    
    func testWithinTimeoutForFail() {
        let sig = Signal("hello")
            .flatMap(longOperation)
        let greeting = try? sig.wait(0.1)
        XCTAssertEqual(greeting, nil)
    }
    
    func testWaitingForFail() {
        do {
            let _ = try Signal("hello")
                .flatMap(asyncOperation)
                .flatMap(fail)
                .wait()
            XCTFail("This place should never be reached due to an error.")
        } catch {
            
        }
    }
}
