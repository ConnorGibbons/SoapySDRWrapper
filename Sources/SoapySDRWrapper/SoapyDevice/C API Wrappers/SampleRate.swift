//
//  SampleRate.swift
//  SoapySDRWrapper
//
//  Created by Connor Gibbons  on 12/3/25.
//

import CSoapySDR

extension SoapyDevice {
    
    // --- Sample Rate API ---
    @discardableResult
    func setRxSampleRate(channel: Int, rate: Double) -> Int {
        Int(SoapySDRDevice_setSampleRate(
            cDevice,
            SoapyDirection.rx.rawValue,
            numericCast(channel),
            rate
        ))
    }
    
    @discardableResult
    func setTxSampleRate(channel: Int, rate: Double) -> Int {
        Int(SoapySDRDevice_setSampleRate(
            cDevice,
            SoapyDirection.tx.rawValue,
            numericCast(channel),
            rate
        ))
    }
    
    func rxSampleRate(channel: Int) -> Double {
        SoapySDRDevice_getSampleRate(cDevice, SoapyDirection.rx.rawValue, numericCast(channel))
    }
    
    func txSampleRate(channel: Int) -> Double {
        SoapySDRDevice_getSampleRate(cDevice, SoapyDirection.tx.rawValue, numericCast(channel))
    }
    
    /// Might get rid of this -- SoapySDR device.h marks it as "deprecated"
    func rxSampleRates(channel: Int) -> [Double] {
        var length: size_t = 0
        guard let ptr = SoapySDRDevice_listSampleRates(
            cDevice,
            SoapyDirection.rx.rawValue,
            numericCast(channel),
            &length
        ) else { return [] }
        let buffer = UnsafeBufferPointer(start: ptr, count: Int(length))
        let rates = Array(buffer)
        SoapySDR_free(ptr)
        return rates
    }
    
    /// Might get rid of this -- SoapySDR device.h marks it as "deprecated"
    func txSampleRates(channel: Int) -> [Double] {
        var length: size_t = 0
        guard let ptr = SoapySDRDevice_listSampleRates(
            cDevice,
            SoapyDirection.tx.rawValue,
            numericCast(channel),
            &length
        ) else { return [] }
        let buffer = UnsafeBufferPointer(start: ptr, count: Int(length))
        let rates = Array(buffer)
        SoapySDR_free(ptr)
        return rates
    }
    
    func rxSampleRateRanges(channel: Int) -> [SoapySDRRange] {
        var length: size_t = 0
        guard let ptr = SoapySDRDevice_getSampleRateRange(
            cDevice,
            SoapyDirection.rx.rawValue,
            numericCast(channel),
            &length
        ) else { return [] }
        let buffer = UnsafeBufferPointer(start: ptr, count: Int(length))
        let ranges = Array(buffer)
        SoapySDR_free(ptr)
        return ranges
    }
    
    func txSampleRateRanges(channel: Int) -> [SoapySDRRange] {
        var length: size_t = 0
        guard let ptr = SoapySDRDevice_getSampleRateRange(
            cDevice,
            SoapyDirection.tx.rawValue,
            numericCast(channel),
            &length
        ) else { return [] }
        let buffer = UnsafeBufferPointer(start: ptr, count: Int(length))
        let ranges = Array(buffer)
        SoapySDR_free(ptr)
        return ranges
    }
    
}
