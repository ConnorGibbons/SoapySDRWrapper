//
//  Clocking.swift
//  SoapySDRWrapper
//
//  Created by Connor Gibbons  on 12/3/25.
//

import CSoapySDR

extension SoapyDevice {

    // --- Clocking API ---
    @discardableResult
    func setMasterClockRate(_ rate: Double) -> Int {
        queue.sync {
            Int(SoapySDRDevice_setMasterClockRate(cDevice, rate))
        }
    }

    var masterClockRate: Double {
        queue.sync {
            SoapySDRDevice_getMasterClockRate(cDevice)
        }
    }

    func masterClockRateRanges() -> [SoapySDRRange] {
        queue.sync {
            var length: size_t = 0
            guard let ptr = SoapySDRDevice_getMasterClockRates(cDevice, &length) else { return [] }
            let buffer = UnsafeBufferPointer(start: ptr, count: Int(length))
            let ranges = Array(buffer)
            SoapySDR_free(ptr)
            return ranges
        }
    }

    @discardableResult
    func setReferenceClockRate(_ rate: Double) -> Int {
        queue.sync {
            Int(SoapySDRDevice_setReferenceClockRate(cDevice, rate))
        }
    }

    var referenceClockRate: Double {
        queue.sync {
            SoapySDRDevice_getReferenceClockRate(cDevice)
        }
    }

    func referenceClockRateRanges() -> [SoapySDRRange] {
        queue.sync {
            var length: size_t = 0
            guard let ptr = SoapySDRDevice_getReferenceClockRates(cDevice, &length) else { return [] }
            let buffer = UnsafeBufferPointer(start: ptr, count: Int(length))
            let ranges = Array(buffer)
            SoapySDR_free(ptr)
            return ranges
        }
    }

    func clockSources() -> [String] {
        queue.sync {
            var length: size_t = 0
            guard let list = SoapySDRDevice_listClockSources(cDevice, &length) else { return [] }
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

    @discardableResult
    func setClockSource(_ source: String) -> Int {
        queue.sync {
            Int(SoapySDRDevice_setClockSource(cDevice, source))
        }
    }

    var clockSource: String? {
        queue.sync {
            guard let ptr = SoapySDRDevice_getClockSource(cDevice) else { return nil }
            defer { SoapySDR_free(ptr) }
            return String(cString: ptr)
        }
    }

}
