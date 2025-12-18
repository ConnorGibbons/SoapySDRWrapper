//
//  Util.swift
//  SoapySDRWrapper
//
//  Created by Connor Gibbons  on 11/20/25.
//
import Foundation

/// Convenience function for getting an UnsafeMutablePointer pointing to memory intialized to a particular value.
/// **Don't forget to call deallocate when done with the pointer!**
func getMutablePointerForValue<T>(value: T) -> UnsafeMutablePointer<T> {
    let pointer = UnsafeMutablePointer<T>.allocate(capacity: 1)
    pointer.initialize(to: value)
    return pointer
}

/// Convenient struct for timing duration of tasks.
/// Starts on init; stops when .stop() is called.
public struct TimeOperation {
    var t0: DispatchTime
    var t1: DispatchTime
    let operationName: String
    
    public init(operationName: String) {
        self.t0 = DispatchTime.distantFuture
        self.t1 = DispatchTime.distantFuture
        self.operationName = operationName
        self.start()
    }
    
    private mutating func start() {
        t0 = .now()
    }
    
    /// Stops timer, returns a string of format: "operationName took (time) ms"
    public mutating func stop() -> String {
        defer {
            t0 = .distantFuture
            t1 = .distantFuture
        }
        t1 = .now()
        guard t0 != .distantFuture else {
            return "\(operationName) never started."
        }
        return "\(operationName) took \(Double(DispatchTime.now().uptimeNanoseconds - t0.uptimeNanoseconds) / 1_000_000) ms"
    }
    
}
