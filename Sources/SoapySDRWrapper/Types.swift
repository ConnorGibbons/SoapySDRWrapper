//
//  Types.swift
//  SoapySDRWrapper
//
//  Created by Connor Gibbons  on 11/25/25.
//
import Foundation
import CSoapySDR

enum SoapyDirection: Int32 {
    case rx = 1
    case tx = 0
}

enum SoapySDRWrapperErrors: Error {
    case deviceInitFailed
}

struct SoapyKwargs {
    var dict: [String: String]
    var cKwargs: SoapySDRKwargs
    
    init(cKwargs: SoapySDRKwargs) {
        self.dict = [:]
        self.cKwargs = cKwargs
        for i in 0..<cKwargs.size {
            guard let keyPtr = cKwargs.keys[i], let valPtr = cKwargs.vals[i] else { continue }
            let key = String(cString: keyPtr); let val = String(cString: valPtr)
            dict.updateValue(val, forKey: key)
        }
    }
    
    /// Gets a mutable pointer to a copy of cKwargs. Don't forget to deallocate after use.
    func getcKwargsMutablePointer() -> UnsafeMutablePointer<SoapySDRKwargs> {
        return getMutablePointerForValue(value: cKwargs)
    }
    
    var description: String {
        var desc = "SoapyKwargs:\n"
        for (k, v) in dict {
            desc += "\(k) = \(v)\n"
        }
        return desc
    }
}

