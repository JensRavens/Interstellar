//
//  Mutex.swift
//  Interstellar
//
//  Created by Jens Ravens on 14/04/16.
//  Copyright © 2016 nerdgeschoss GmbH. All rights reserved.
//

import Foundation
#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

internal class Mutex {
    fileprivate var mutex = pthread_mutex_t()
    
    init() {
        pthread_mutex_init(&mutex, nil)
    }
    
    deinit {
        pthread_mutex_destroy(&mutex)
    }
    
    func lock() -> Int32 {
        return pthread_mutex_lock(&mutex)
    }
    
    @discardableResult func unlock() -> Int32 {
        return pthread_mutex_unlock(&mutex)
    }
    
    func lock(_ closure: () -> Void) {
        let status = lock()
        assert(status == 0, "pthread_mutex_lock: \(strerror(status))")
        defer { unlock() }
        closure()
    }
}
