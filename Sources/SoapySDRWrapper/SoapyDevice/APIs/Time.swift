//
//  Time.swift
//  SoapySDRWrapper
//
//  Created by Connor Gibbons  on 12/3/25.
//

import CSoapySDR

extension SoapyDevice {
    
    // --- Time API ---
    func timeSources() -> [String] {
        var length: size_t = 0
        guard let list = SoapySDRDevice_listTimeSources(cDevice, &length) else { return [] }
        var result: [String] = []
        for i in 0..<Int(length) {
            if let ptr = list[i] {
                result.append(String(cString: ptr))
                SoapySDR_free(ptr)
            }
        }
        return result
    }
    
    @discardableResult
    func setTimeSource(_ source: String) -> Int {
        Int(SoapySDRDevice_setTimeSource(cDevice, source))
    }
    
    var timeSource: String? {
        guard let ptr = SoapySDRDevice_getTimeSource(cDevice) else { return nil }
        defer { SoapySDR_free(ptr) }
        return String(cString: ptr)
    }
    
    func hasHardwareTime(what: String? = nil) -> Bool {
        if let what = what {
            return SoapySDRDevice_hasHardwareTime(cDevice, what)
        } else {
            return SoapySDRDevice_hasHardwareTime(cDevice, nil)
        }
    }
    
    func hardwareTime(what: String? = nil) -> Int64 {
        if let what = what {
            return SoapySDRDevice_getHardwareTime(cDevice, what)
        } else {
            return SoapySDRDevice_getHardwareTime(cDevice, nil)
        }
    }
    
    @discardableResult
    func setHardwareTime(_ timeNs: Int64, what: String? = nil) -> Int {
        if let what = what {
            return Int(SoapySDRDevice_setHardwareTime(cDevice, timeNs, what))
        } else {
            return Int(SoapySDRDevice_setHardwareTime(cDevice, timeNs, nil))
        }
    }
    
    @discardableResult
    func setCommandTime(_ timeNs: Int64, what: String? = nil) -> Int {
        if let what = what {
            return Int(SoapySDRDevice_setCommandTime(cDevice, timeNs, what))
        } else {
            return Int(SoapySDRDevice_setCommandTime(cDevice, timeNs, nil))
        }
    }
    
}
