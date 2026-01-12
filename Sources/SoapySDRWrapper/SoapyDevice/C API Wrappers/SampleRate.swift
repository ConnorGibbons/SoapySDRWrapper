//
//  SampleRate.swift
//  SoapySDRWrapper
//
//  Created by Connor Gibbons  on 12/3/25.
//

import CSoapySDR

extension SoapyDevice {

    // --- Sample Rate API ---
    public func setSampleRate(direction: SoapyDirection, channel: Int, rate: Double) throws {
        try queue.sync {
            try SoapySDRMaybeThrowError(code: SoapySDRDevice_setSampleRate(
                cDevice,
                direction.rawValue,
                numericCast(channel),
                rate
            ))
        }
    }

    public func sampleRate(direction: SoapyDirection, channel: Int) -> Double {
        queue.sync {
            SoapySDRDevice_getSampleRate(cDevice, direction.rawValue, numericCast(channel))
        }
    }

    /// Might get rid of this -- SoapySDR device.h marks it as "deprecated"
    public func sampleRates(direction: SoapyDirection, channel: Int) -> [Double] {
        queue.sync {
            var length: size_t = 0
            guard let ptr = SoapySDRDevice_listSampleRates(
                cDevice,
                direction.rawValue,
                numericCast(channel),
                &length
            ) else { return [] }
            let buffer = UnsafeBufferPointer(start: ptr, count: Int(length))
            let rates = Array(buffer)
            SoapySDR_free(ptr)
            return rates
        }
    }

    public func sampleRateRanges(direction: SoapyDirection, channel: Int) -> [SoapySDRRange] {
        queue.sync {
            var length: size_t = 0
            guard let ptr = SoapySDRDevice_getSampleRateRange(
                cDevice,
                direction.rawValue,
                numericCast(channel),
                &length
            ) else { return [] }
            let buffer = UnsafeBufferPointer(start: ptr, count: Int(length))
            let ranges = Array(buffer)
            SoapySDR_free(ptr)
            return ranges
        }
    }

}
