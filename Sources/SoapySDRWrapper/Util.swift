//
//  Util.swift
//  SoapySDRWrapper
//
//  Created by Connor Gibbons  on 11/20/25.
//

/// Convenience function for getting an UnsafeMutablePointer pointing to memory intialized to a particular value.
/// **Don't forget to call deallocate when done with the pointer!**
func getMutablePointerForValue<T>(value: T) -> UnsafeMutablePointer<T> {
    let pointer = UnsafeMutablePointer<T>.allocate(capacity: 1)
    pointer.initialize(to: value)
    return pointer
}


