//
//  Bandwidth.swift
//  SoapySDRWrapper
//
//  Created by Connor Gibbons  on 12/3/25.
//

import CSoapySDR

extension SoapyDevice {
    
    // --- Bandwidth API ---
    @discardableResult
    func setRxBandwidth(channel: Int, bw: Double) -> Int {
        Int(SoapySDRDevice_setBandwidth(
            cDevice,
            SoapyDirection.rx.rawValue,
            numericCast(channel),
            bw
        ))
    }
    
    @discardableResult
    func setTxBandwidth(channel: Int, bw: Double) -> Int {
        Int(SoapySDRDevice_setBandwidth(
            cDevice,
            SoapyDirection.tx.rawValue,
            numericCast(channel),
            bw
        ))
    }
    
    func rxBandwidth(channel: Int) -> Double {
        SoapySDRDevice_getBandwidth(cDevice, SoapyDirection.rx.rawValue, numericCast(channel))
    }
    
    func txBandwidth(channel: Int) -> Double {
        SoapySDRDevice_getBandwidth(cDevice, SoapyDirection.tx.rawValue, numericCast(channel))
    }
    
    func rxBandwidths(channel: Int) -> [Double] {
        var length: size_t = 0
        guard let ptr = SoapySDRDevice_listBandwidths(
            cDevice,
            SoapyDirection.rx.rawValue,
            numericCast(channel),
            &length
        ) else { return [] }
        let buffer = UnsafeBufferPointer(start: ptr, count: Int(length))
        let bws = Array(buffer)
        SoapySDR_free(ptr)
        return bws
    }
    
    func txBandwidths(channel: Int) -> [Double] {
        var length: size_t = 0
        guard let ptr = SoapySDRDevice_listBandwidths(
            cDevice,
            SoapyDirection.tx.rawValue,
            numericCast(channel),
            &length
        ) else { return [] }
        let buffer = UnsafeBufferPointer(start: ptr, count: Int(length))
        let bws = Array(buffer)
        SoapySDR_free(ptr)
        return bws
    }
    
    func rxBandwidthRanges(channel: Int) -> [SoapySDRRange] {
        var length: size_t = 0
        guard let ptr = SoapySDRDevice_getBandwidthRange(
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
    
    func txBandwidthRanges(channel: Int) -> [SoapySDRRange] {
        var length: size_t = 0
        guard let ptr = SoapySDRDevice_getBandwidthRange(
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
