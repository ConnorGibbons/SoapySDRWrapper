//
//  Time.swift
//  SoapySDRWrapper
//
//  Created by Connor Gibbons  on 12/3/25.
//

import CSoapySDR

extension SoapyDevice {

    // --- Time API ---
    public func timeSources() -> [String] {
        queue.sync {
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
    }

    public func setTimeSource(_ source: String) throws {
        try queue.sync {
            try SoapySDRMaybeThrowError(code: SoapySDRDevice_setTimeSource(cDevice, source))
        }
    }

    public var timeSource: String? {
        queue.sync {
            guard let ptr = SoapySDRDevice_getTimeSource(cDevice) else { return nil }
            defer { SoapySDR_free(ptr) }
            return String(cString: ptr)
        }
    }

    public func hasHardwareTime(what: String? = nil) -> Bool {
        queue.sync {
            if let what = what {
                return SoapySDRDevice_hasHardwareTime(cDevice, what)
            } else {
                return SoapySDRDevice_hasHardwareTime(cDevice, nil)
            }
        }
    }

    public func hardwareTime(what: String? = nil) -> Int64 {
        queue.sync {
            if let what = what {
                return SoapySDRDevice_getHardwareTime(cDevice, what)
            } else {
                return SoapySDRDevice_getHardwareTime(cDevice, nil)
            }
        }
    }

    public func setHardwareTime(_ timeNs: Int64, what: String? = nil) throws {
        try queue.sync {
            if let what = what {
                try SoapySDRMaybeThrowError(code: SoapySDRDevice_setHardwareTime(cDevice, timeNs, what))
            } else {
                try SoapySDRMaybeThrowError(code: SoapySDRDevice_setHardwareTime(cDevice, timeNs, nil))
            }
        }
    }

    public func setCommandTime(_ timeNs: Int64, what: String? = nil) throws {
        try queue.sync {
            if let what = what {
                try SoapySDRMaybeThrowError(code: SoapySDRDevice_setCommandTime(cDevice, timeNs, what))
            } else {
                try SoapySDRMaybeThrowError(code: SoapySDRDevice_setCommandTime(cDevice, timeNs, nil))
            }
        }
    }

}
