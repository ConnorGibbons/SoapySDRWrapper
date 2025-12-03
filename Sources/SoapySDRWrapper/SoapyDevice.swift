//
//  SoapyDevice.swift
//  SoapySDRWrapper
//
//  Created by Connor Gibbons  on 11/25/25.
//
import Foundation
import CSoapySDR

class SoapyDevice {
    let cDevice: OpaquePointer
    
    // --- Device Metadata ---
    var driverName: String? {
        guard let driverNamePtr = SoapySDRDevice_getDriverKey(cDevice) else { return nil }
        defer { SoapySDR_free(driverNamePtr) }
        return String(cString: driverNamePtr)
    }
    
    var hardwareName: String? {
        guard let hardwareNamePtr = SoapySDRDevice_getHardwareKey(cDevice) else { return nil }
        defer { SoapySDR_free(hardwareNamePtr) }
        return String(cString: hardwareNamePtr)
    }
    
    var hardwareKwargs: SoapyKwargs {
        return SoapyKwargs(cKwargs: SoapySDRDevice_getHardwareInfo(cDevice))
    }
    
    // --- Device RX/TX Capabilities ---
    var rxFrontendMapping: String? {
        guard let mappingPtr = SoapySDRDevice_getFrontendMapping(cDevice, SoapyDirection.rx.rawValue) else {
            return nil
        }
        defer { SoapySDR_free(mappingPtr) }
        return String(cString: mappingPtr)
    }
    
    var txFrontendMapping: String? {
        guard let mappingPtr = SoapySDRDevice_getFrontendMapping(cDevice, SoapyDirection.tx.rawValue) else {
            return nil
        }
        defer { SoapySDR_free(mappingPtr) }
        return String(cString: mappingPtr)
    }
    
//    @discardableResult
//    func setRxFrontendMapping(_ mapping: String) -> Int {
//        Int(SoapySDRDevice_setFrontendMapping(cDevice, SoapyDirection.rx.rawValue, mapping))
//    }
//    
//    @discardableResult
//    func setTxFrontendMapping(_ mapping: String) -> Int {
//        Int(SoapySDRDevice_setFrontendMapping(cDevice, SoapyDirection.tx.rawValue, mapping))
//    }
    
    var rxNumChannels: Int {
        Int(SoapySDRDevice_getNumChannels(cDevice, SoapyDirection.rx.rawValue))
    }
    
    var txNumChannels: Int {
        Int(SoapySDRDevice_getNumChannels(cDevice, SoapyDirection.tx.rawValue))
    }
    
    func rxChannelInfo(channel: Int) -> SoapyKwargs {
        let info = SoapySDRDevice_getChannelInfo(
            cDevice,
            SoapyDirection.rx.rawValue,
            numericCast(channel)
        )
        return SoapyKwargs(cKwargs: info)
    }
    
    func txChannelInfo(channel: Int) -> SoapyKwargs {
        let info = SoapySDRDevice_getChannelInfo(
            cDevice,
            SoapyDirection.tx.rawValue,
            numericCast(channel)
        )
        return SoapyKwargs(cKwargs: info)
    }
    
    func rxIsFullDuplex(channel: Int) -> Bool {
        SoapySDRDevice_getFullDuplex(
            cDevice,
            SoapyDirection.rx.rawValue,
            numericCast(channel)
        )
    }
    
    func txIsFullDuplex(channel: Int) -> Bool {
        SoapySDRDevice_getFullDuplex(
            cDevice,
            SoapyDirection.tx.rawValue,
            numericCast(channel)
        )
    }
    
    // --- Antenna API ---
    func rxAntennas(channel: Int) -> [String] {
        var length: size_t = 0
        guard let list = SoapySDRDevice_listAntennas(
            cDevice,
            SoapyDirection.rx.rawValue,
            numericCast(channel),
            &length
        ) else { return [] }
        
        var result: [String] = []
        for i in 0..<Int(length) {
            if let ptr = list[i] {
                result.append(String(cString: ptr))
                SoapySDR_free(ptr)
            }
        }
        
        return result
    }
    
    func txAntennas(channel: Int) -> [String] {
        var length: size_t = 0
        guard let list = SoapySDRDevice_listAntennas(
            cDevice,
            SoapyDirection.tx.rawValue,
            numericCast(channel),
            &length
        ) else { return [] }
        
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
    func setRxAntenna(channel: Int, name: String) -> Int {
        Int(SoapySDRDevice_setAntenna(
            cDevice,
            SoapyDirection.rx.rawValue,
            numericCast(channel),
            name
        ))
    }
    
    @discardableResult
    func setTxAntenna(channel: Int, name: String) -> Int {
        Int(SoapySDRDevice_setAntenna(
            cDevice,
            SoapyDirection.tx.rawValue,
            numericCast(channel),
            name
        ))
    }
    
    func rxAntenna(channel: Int) -> String? {
        guard let ptr = SoapySDRDevice_getAntenna(
            cDevice,
            SoapyDirection.rx.rawValue,
            numericCast(channel)
        ) else { return nil }
        defer { SoapySDR_free(ptr) }
        return String(cString: ptr)
    }
    
    func txAntenna(channel: Int) -> String? {
        guard let ptr = SoapySDRDevice_getAntenna(
            cDevice,
            SoapyDirection.tx.rawValue,
            numericCast(channel)
        ) else { return nil }
        defer { SoapySDR_free(ptr) }
        return String(cString: ptr)
    }
    
    // --- Frontend Corrections API ---
    
    /// Returns 'true' if automatic DC offset mode is supported by the device for this RX channel.
    func rxHasDCOffsetMode(channel: Int) -> Bool {
        SoapySDRDevice_hasDCOffsetMode(cDevice, SoapyDirection.rx.rawValue, numericCast(channel))
    }
    
    /// Returns 'true' if automatic DC offset mode is supported by the device for this TX channel.
    func txHasDCOffsetMode(channel: Int) -> Bool {
        SoapySDRDevice_hasDCOffsetMode(cDevice, SoapyDirection.tx.rawValue, numericCast(channel))
    }
    
    @discardableResult
    func setRxDCOffsetMode(channel: Int, automatic: Bool) -> Int {
        Int(SoapySDRDevice_setDCOffsetMode(
            cDevice,
            SoapyDirection.rx.rawValue,
            numericCast(channel),
            automatic
        ))
    }
    
    @discardableResult
    func setTxDCOffsetMode(channel: Int, automatic: Bool) -> Int {
        Int(SoapySDRDevice_setDCOffsetMode(
            cDevice,
            SoapyDirection.tx.rawValue,
            numericCast(channel),
            automatic
        ))
    }
    
    func rxDCOffsetMode(channel: Int) -> Bool {
        SoapySDRDevice_getDCOffsetMode(cDevice, SoapyDirection.rx.rawValue, numericCast(channel))
    }
    
    func txDCOffsetMode(channel: Int) -> Bool {
        SoapySDRDevice_getDCOffsetMode(cDevice, SoapyDirection.tx.rawValue, numericCast(channel))
    }
    
    func rxHasDCOffset(channel: Int) -> Bool {
        SoapySDRDevice_hasDCOffset(cDevice, SoapyDirection.rx.rawValue, numericCast(channel))
    }
    
    func txHasDCOffset(channel: Int) -> Bool {
        SoapySDRDevice_hasDCOffset(cDevice, SoapyDirection.tx.rawValue, numericCast(channel))
    }
    
    @discardableResult
    func setRxDCOffset(channel: Int, offsetI: Double, offsetQ: Double) -> Int {
        Int(SoapySDRDevice_setDCOffset(
            cDevice,
            SoapyDirection.rx.rawValue,
            numericCast(channel),
            offsetI,
            offsetQ
        ))
    }
    
    @discardableResult
    func setTxDCOffset(channel: Int, offsetI: Double, offsetQ: Double) -> Int {
        Int(SoapySDRDevice_setDCOffset(
            cDevice,
            SoapyDirection.tx.rawValue,
            numericCast(channel),
            offsetI,
            offsetQ
        ))
    }
    
    func rxDCOffset(channel: Int) -> (offsetI: Double, offsetQ: Double)? {
        var i: Double = 0
        var q: Double = 0
        let status = SoapySDRDevice_getDCOffset(
            cDevice,
            SoapyDirection.rx.rawValue,
            numericCast(channel),
            &i,
            &q
        )
        guard status == 0 else { return nil }
        return (i, q)
    }
    
    func txDCOffset(channel: Int) -> (offsetI: Double, offsetQ: Double)? {
        var i: Double = 0
        var q: Double = 0
        let status = SoapySDRDevice_getDCOffset(
            cDevice,
            SoapyDirection.tx.rawValue,
            numericCast(channel),
            &i,
            &q
        )
        guard status == 0 else { return nil }
        return (i, q)
    }
    
    func rxHasIQBalance(channel: Int) -> Bool {
        SoapySDRDevice_hasIQBalance(cDevice, SoapyDirection.rx.rawValue, numericCast(channel))
    }
    
    func txHasIQBalance(channel: Int) -> Bool {
        SoapySDRDevice_hasIQBalance(cDevice, SoapyDirection.tx.rawValue, numericCast(channel))
    }
    
    @discardableResult
    func setRxIQBalance(channel: Int, balanceI: Double, balanceQ: Double) -> Int {
        Int(SoapySDRDevice_setIQBalance(
            cDevice,
            SoapyDirection.rx.rawValue,
            numericCast(channel),
            balanceI,
            balanceQ
        ))
    }
    
    @discardableResult
    func setTxIQBalance(channel: Int, balanceI: Double, balanceQ: Double) -> Int {
        Int(SoapySDRDevice_setIQBalance(
            cDevice,
            SoapyDirection.tx.rawValue,
            numericCast(channel),
            balanceI,
            balanceQ
        ))
    }
    
    func rxIQBalance(channel: Int) -> (balanceI: Double, balanceQ: Double)? {
        var i: Double = 0
        var q: Double = 0
        let status = SoapySDRDevice_getIQBalance(
            cDevice,
            SoapyDirection.rx.rawValue,
            numericCast(channel),
            &i,
            &q
        )
        guard status == 0 else { return nil }
        return (i, q)
    }
    
    func txIQBalance(channel: Int) -> (balanceI: Double, balanceQ: Double)? {
        var i: Double = 0
        var q: Double = 0
        let status = SoapySDRDevice_getIQBalance(
            cDevice,
            SoapyDirection.tx.rawValue,
            numericCast(channel),
            &i,
            &q
        )
        guard status == 0 else { return nil }
        return (i, q)
    }
    
    func rxHasIQBalanceMode(channel: Int) -> Bool {
        SoapySDRDevice_hasIQBalanceMode(cDevice, SoapyDirection.rx.rawValue, numericCast(channel))
    }
    
    func txHasIQBalanceMode(channel: Int) -> Bool {
        SoapySDRDevice_hasIQBalanceMode(cDevice, SoapyDirection.tx.rawValue, numericCast(channel))
    }
    
    @discardableResult
    func setRxIQBalanceMode(channel: Int, automatic: Bool) -> Int {
        Int(SoapySDRDevice_setIQBalanceMode(
            cDevice,
            SoapyDirection.rx.rawValue,
            numericCast(channel),
            automatic
        ))
    }
    
    @discardableResult
    func setTxIQBalanceMode(channel: Int, automatic: Bool) -> Int {
        Int(SoapySDRDevice_setIQBalanceMode(
            cDevice,
            SoapyDirection.tx.rawValue,
            numericCast(channel),
            automatic
        ))
    }
    
    func rxIQBalanceMode(channel: Int) -> Bool {
        SoapySDRDevice_getIQBalanceMode(cDevice, SoapyDirection.rx.rawValue, numericCast(channel))
    }
    
    func txIQBalanceMode(channel: Int) -> Bool {
        SoapySDRDevice_getIQBalanceMode(cDevice, SoapyDirection.tx.rawValue, numericCast(channel))
    }
    
    func rxHasFrequencyCorrection(channel: Int) -> Bool {
        SoapySDRDevice_hasFrequencyCorrection(cDevice, SoapyDirection.rx.rawValue, numericCast(channel))
    }
    
    func txHasFrequencyCorrection(channel: Int) -> Bool {
        SoapySDRDevice_hasFrequencyCorrection(cDevice, SoapyDirection.tx.rawValue, numericCast(channel))
    }
    
    @discardableResult
    func setRxFrequencyCorrection(channel: Int, ppm: Double) -> Int {
        Int(SoapySDRDevice_setFrequencyCorrection(
            cDevice,
            SoapyDirection.rx.rawValue,
            numericCast(channel),
            ppm
        ))
    }
    
    @discardableResult
    func setTxFrequencyCorrection(channel: Int, ppm: Double) -> Int {
        Int(SoapySDRDevice_setFrequencyCorrection(
            cDevice,
            SoapyDirection.tx.rawValue,
            numericCast(channel),
            ppm
        ))
    }
    
    func rxFrequencyCorrection(channel: Int) -> Double {
        SoapySDRDevice_getFrequencyCorrection(cDevice, SoapyDirection.rx.rawValue, numericCast(channel))
    }
    
    func txFrequencyCorrection(channel: Int) -> Double {
        SoapySDRDevice_getFrequencyCorrection(cDevice, SoapyDirection.tx.rawValue, numericCast(channel))
    }
    
    // --- Gain API ---
    func rxGainElements(channel: Int) -> [String] {
        var length: size_t = 0
        guard let list = SoapySDRDevice_listGains(
            cDevice,
            SoapyDirection.rx.rawValue,
            numericCast(channel),
            &length
        ) else { return [] }
        
        var result: [String] = []
        for i in 0..<Int(length) {
            if let ptr = list[i] {
                result.append(String(cString: ptr))
                SoapySDR_free(ptr)
            }
        }
        return result
    }
    
    func txGainElements(channel: Int) -> [String] {
        var length: size_t = 0
        guard let list = SoapySDRDevice_listGains(
            cDevice,
            SoapyDirection.tx.rawValue,
            numericCast(channel),
            &length
        ) else { return [] }
        
        var result: [String] = []
        for i in 0..<Int(length) {
            if let ptr = list[i] {
                result.append(String(cString: ptr))
                SoapySDR_free(ptr)
            }
        }
        return result
    }
    
    func rxHasGainMode(channel: Int) -> Bool {
        SoapySDRDevice_hasGainMode(cDevice, SoapyDirection.rx.rawValue, numericCast(channel))
    }
    
    func txHasGainMode(channel: Int) -> Bool {
        SoapySDRDevice_hasGainMode(cDevice, SoapyDirection.tx.rawValue, numericCast(channel))
    }
    
    @discardableResult
    func setRxGainMode(channel: Int, automatic: Bool) -> Int {
        Int(SoapySDRDevice_setGainMode(
            cDevice,
            SoapyDirection.rx.rawValue,
            numericCast(channel),
            automatic
        ))
    }
    
    @discardableResult
    func setTxGainMode(channel: Int, automatic: Bool) -> Int {
        Int(SoapySDRDevice_setGainMode(
            cDevice,
            SoapyDirection.tx.rawValue,
            numericCast(channel),
            automatic
        ))
    }
    
    func rxGainMode(channel: Int) -> Bool {
        SoapySDRDevice_getGainMode(cDevice, SoapyDirection.rx.rawValue, numericCast(channel))
    }
    
    func txGainMode(channel: Int) -> Bool {
        SoapySDRDevice_getGainMode(cDevice, SoapyDirection.tx.rawValue, numericCast(channel))
    }
    
    @discardableResult
    func setRxGain(channel: Int, value: Double) -> Int {
        Int(SoapySDRDevice_setGain(
            cDevice,
            SoapyDirection.rx.rawValue,
            numericCast(channel),
            value
        ))
    }
    
    @discardableResult
    func setTxGain(channel: Int, value: Double) -> Int {
        Int(SoapySDRDevice_setGain(
            cDevice,
            SoapyDirection.tx.rawValue,
            numericCast(channel),
            value
        ))
    }
    
    @discardableResult
    func setRxGain(channel: Int, element name: String, value: Double) -> Int {
        Int(SoapySDRDevice_setGainElement(
            cDevice,
            SoapyDirection.rx.rawValue,
            numericCast(channel),
            name,
            value
        ))
    }
    
    @discardableResult
    func setTxGain(channel: Int, element name: String, value: Double) -> Int {
        Int(SoapySDRDevice_setGainElement(
            cDevice,
            SoapyDirection.tx.rawValue,
            numericCast(channel),
            name,
            value
        ))
    }
    
    func rxGain(channel: Int) -> Double {
        SoapySDRDevice_getGain(cDevice, SoapyDirection.rx.rawValue, numericCast(channel))
    }
    
    func txGain(channel: Int) -> Double {
        SoapySDRDevice_getGain(cDevice, SoapyDirection.tx.rawValue, numericCast(channel))
    }
    
    func rxGain(channel: Int, element name: String) -> Double {
        SoapySDRDevice_getGainElement(
            cDevice,
            SoapyDirection.rx.rawValue,
            numericCast(channel),
            name
        )
    }
    
    func txGain(channel: Int, element name: String) -> Double {
        SoapySDRDevice_getGainElement(
            cDevice,
            SoapyDirection.tx.rawValue,
            numericCast(channel),
            name
        )
    }
    
    func rxGainRange(channel: Int) -> SoapySDRRange {
        SoapySDRDevice_getGainRange(cDevice, SoapyDirection.rx.rawValue, numericCast(channel))
    }
    
    func txGainRange(channel: Int) -> SoapySDRRange {
        SoapySDRDevice_getGainRange(cDevice, SoapyDirection.tx.rawValue, numericCast(channel))
    }
    
    func rxGainElementRange(channel: Int, element name: String) -> SoapySDRRange {
        SoapySDRDevice_getGainElementRange(
            cDevice,
            SoapyDirection.rx.rawValue,
            numericCast(channel),
            name
        )
    }
    
    func txGainElementRange(channel: Int, element name: String) -> SoapySDRRange {
        SoapySDRDevice_getGainElementRange(
            cDevice,
            SoapyDirection.tx.rawValue,
            numericCast(channel),
            name
        )
    }
    
    // --- Frequency API ---
    @discardableResult
    func setRxFrequency(channel: Int, frequency: Double, args: SoapyKwargs? = nil) -> Int {
        if var cArgs = args?.cKwargs {
            return Int(SoapySDRDevice_setFrequency(
                cDevice,
                SoapyDirection.rx.rawValue,
                numericCast(channel),
                frequency,
                &cArgs
            ))
        } else {
            return Int(SoapySDRDevice_setFrequency(
                cDevice,
                SoapyDirection.rx.rawValue,
                numericCast(channel),
                frequency,
                nil
            ))
        }
    }
    
    @discardableResult
    func setTxFrequency(channel: Int, frequency: Double, args: SoapyKwargs? = nil) -> Int {
        if var cArgs = args?.cKwargs {
            return Int(SoapySDRDevice_setFrequency(
                cDevice,
                SoapyDirection.tx.rawValue,
                numericCast(channel),
                frequency,
                &cArgs
            ))
        } else {
            return Int(SoapySDRDevice_setFrequency(
                cDevice,
                SoapyDirection.tx.rawValue,
                numericCast(channel),
                frequency,
                nil
            ))
        }
    }
    
    @discardableResult
    func setRxFrequencyComponent(channel: Int, name: String, frequency: Double, args: SoapyKwargs? = nil) -> Int {
        if var cArgs = args?.cKwargs {
            return Int(SoapySDRDevice_setFrequencyComponent(
                cDevice,
                SoapyDirection.rx.rawValue,
                numericCast(channel),
                name,
                frequency,
                &cArgs
            ))
        } else {
            return Int(SoapySDRDevice_setFrequencyComponent(
                cDevice,
                SoapyDirection.rx.rawValue,
                numericCast(channel),
                name,
                frequency,
                nil
            ))
        }
    }
    
    @discardableResult
    func setTxFrequencyComponent(channel: Int, name: String, frequency: Double, args: SoapyKwargs? = nil) -> Int {
        if var cArgs = args?.cKwargs {
            return Int(SoapySDRDevice_setFrequencyComponent(
                cDevice,
                SoapyDirection.tx.rawValue,
                numericCast(channel),
                name,
                frequency,
                &cArgs
            ))
        } else {
            return Int(SoapySDRDevice_setFrequencyComponent(
                cDevice,
                SoapyDirection.tx.rawValue,
                numericCast(channel),
                name,
                frequency,
                nil
            ))
        }
    }
    
    func rxFrequency(channel: Int) -> Double {
        SoapySDRDevice_getFrequency(cDevice, SoapyDirection.rx.rawValue, numericCast(channel))
    }
    
    func txFrequency(channel: Int) -> Double {
        SoapySDRDevice_getFrequency(cDevice, SoapyDirection.tx.rawValue, numericCast(channel))
    }
    
    func rxFrequencyComponent(channel: Int, name: String) -> Double {
        SoapySDRDevice_getFrequencyComponent(
            cDevice,
            SoapyDirection.rx.rawValue,
            numericCast(channel),
            name
        )
    }
    
    func txFrequencyComponent(channel: Int, name: String) -> Double {
        SoapySDRDevice_getFrequencyComponent(
            cDevice,
            SoapyDirection.tx.rawValue,
            numericCast(channel),
            name
        )
    }
    
    func rxFrequencyElements(channel: Int) -> [String] {
        var length: size_t = 0
        guard let list = SoapySDRDevice_listFrequencies(
            cDevice,
            SoapyDirection.rx.rawValue,
            numericCast(channel),
            &length
        ) else { return [] }
        
        var result: [String] = []
        for i in 0..<Int(length) {
            if let ptr = list[i] {
                result.append(String(cString: ptr))
                SoapySDR_free(ptr)
            }
        }
        return result
    }
    
    func txFrequencyElements(channel: Int) -> [String] {
        var length: size_t = 0
        guard let list = SoapySDRDevice_listFrequencies(
            cDevice,
            SoapyDirection.tx.rawValue,
            numericCast(channel),
            &length
        ) else { return [] }
        
        var result: [String] = []
        for i in 0..<Int(length) {
            if let ptr = list[i] {
                result.append(String(cString: ptr))
                SoapySDR_free(ptr)
            }
        }
        return result
    }
    
    func rxFrequencyRange(channel: Int) -> [SoapySDRRange] {
        var length: size_t = 0
        guard let ptr = SoapySDRDevice_getFrequencyRange(
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
    
    func txFrequencyRange(channel: Int) -> [SoapySDRRange] {
        var length: size_t = 0
        guard let ptr = SoapySDRDevice_getFrequencyRange(
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
    
    func rxFrequencyRange(channel: Int, element name: String) -> [SoapySDRRange] {
        var length: size_t = 0
        guard let ptr = SoapySDRDevice_getFrequencyRangeComponent(
            cDevice,
            SoapyDirection.rx.rawValue,
            numericCast(channel),
            name,
            &length
        ) else { return [] }
        
        let buffer = UnsafeBufferPointer(start: ptr, count: Int(length))
        let ranges = Array(buffer)
        SoapySDR_free(ptr)
        return ranges
    }
    
    func txFrequencyRange(channel: Int, element name: String) -> [SoapySDRRange] {
        var length: size_t = 0
        guard let ptr = SoapySDRDevice_getFrequencyRangeComponent(
            cDevice,
            SoapyDirection.tx.rawValue,
            numericCast(channel),
            name,
            &length
        ) else { return [] }
        
        let buffer = UnsafeBufferPointer(start: ptr, count: Int(length))
        let ranges = Array(buffer)
        SoapySDR_free(ptr)
        return ranges
    }
    
    func rxFrequencyArgsInfo(channel: Int) -> [SoapySDRArgInfo] {
        var length: size_t = 0
        guard let ptr = SoapySDRDevice_getFrequencyArgsInfo(
            cDevice,
            SoapyDirection.rx.rawValue,
            numericCast(channel),
            &length
        ) else { return [] }
        let buffer = UnsafeBufferPointer(start: ptr, count: Int(length))
        let info = Array(buffer)
        // ArgInfoList_clear would invalidate copied structs; leak is preferable here.
        return info
    }
    
    func txFrequencyArgsInfo(channel: Int) -> [SoapySDRArgInfo] {
        var length: size_t = 0
        guard let ptr = SoapySDRDevice_getFrequencyArgsInfo(
            cDevice,
            SoapyDirection.tx.rawValue,
            numericCast(channel),
            &length
        ) else { return [] }
        let buffer = UnsafeBufferPointer(start: ptr, count: Int(length))
        let info = Array(buffer)
        return info
    }
    
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
    
    // --- Clocking API ---
    @discardableResult
    func setMasterClockRate(_ rate: Double) -> Int {
        Int(SoapySDRDevice_setMasterClockRate(cDevice, rate))
    }
    
    var masterClockRate: Double {
        SoapySDRDevice_getMasterClockRate(cDevice)
    }
    
    func masterClockRateRanges() -> [SoapySDRRange] {
        var length: size_t = 0
        guard let ptr = SoapySDRDevice_getMasterClockRates(cDevice, &length) else { return [] }
        let buffer = UnsafeBufferPointer(start: ptr, count: Int(length))
        let ranges = Array(buffer)
        SoapySDR_free(ptr)
        return ranges
    }
    
    @discardableResult
    func setReferenceClockRate(_ rate: Double) -> Int {
        Int(SoapySDRDevice_setReferenceClockRate(cDevice, rate))
    }
    
    var referenceClockRate: Double {
        SoapySDRDevice_getReferenceClockRate(cDevice)
    }
    
    func referenceClockRateRanges() -> [SoapySDRRange] {
        var length: size_t = 0
        guard let ptr = SoapySDRDevice_getReferenceClockRates(cDevice, &length) else { return [] }
        let buffer = UnsafeBufferPointer(start: ptr, count: Int(length))
        let ranges = Array(buffer)
        SoapySDR_free(ptr)
        return ranges
    }
    
    func clockSources() -> [String] {
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
    
    @discardableResult
    func setClockSource(_ source: String) -> Int {
        Int(SoapySDRDevice_setClockSource(cDevice, source))
    }
    
    var clockSource: String? {
        guard let ptr = SoapySDRDevice_getClockSource(cDevice) else { return nil }
        defer { SoapySDR_free(ptr) }
        return String(cString: ptr)
    }
    
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
    
    // --- Sensor API ---
    func sensors() -> [String] {
        var length: size_t = 0
        guard let list = SoapySDRDevice_listSensors(cDevice, &length) else { return [] }
        var result: [String] = []
        for i in 0..<Int(length) {
            if let ptr = list[i] {
                result.append(String(cString: ptr))
                SoapySDR_free(ptr)
            }
        }
        return result
    }
    
    func sensorInfo(_ key: String) -> SoapySDRArgInfo {
        SoapySDRDevice_getSensorInfo(cDevice, key)
    }
    
    func readSensor(_ key: String) -> String? {
        guard let ptr = SoapySDRDevice_readSensor(cDevice, key) else { return nil }
        defer { SoapySDR_free(ptr) }
        return String(cString: ptr)
    }
    
    func rxChannelSensors(channel: Int) -> [String] {
        var length: size_t = 0
        guard let list = SoapySDRDevice_listChannelSensors(
            cDevice,
            SoapyDirection.rx.rawValue,
            numericCast(channel),
            &length
        ) else { return [] }
        var result: [String] = []
        for i in 0..<Int(length) {
            if let ptr = list[i] {
                result.append(String(cString: ptr))
                SoapySDR_free(ptr)
            }
        }
        return result
    }
    
    func txChannelSensors(channel: Int) -> [String] {
        var length: size_t = 0
        guard let list = SoapySDRDevice_listChannelSensors(
            cDevice,
            SoapyDirection.tx.rawValue,
            numericCast(channel),
            &length
        ) else { return [] }
        var result: [String] = []
        for i in 0..<Int(length) {
            if let ptr = list[i] {
                result.append(String(cString: ptr))
                SoapySDR_free(ptr)
            }
        }
        return result
    }
    
    func rxChannelSensorInfo(channel: Int, key: String) -> SoapySDRArgInfo {
        SoapySDRDevice_getChannelSensorInfo(
            cDevice,
            SoapyDirection.rx.rawValue,
            numericCast(channel),
            key
        )
    }
    
    func txChannelSensorInfo(channel: Int, key: String) -> SoapySDRArgInfo {
        SoapySDRDevice_getChannelSensorInfo(
            cDevice,
            SoapyDirection.tx.rawValue,
            numericCast(channel),
            key
        )
    }
    
    func readRxChannelSensor(channel: Int, key: String) -> String? {
        guard let ptr = SoapySDRDevice_readChannelSensor(
            cDevice,
            SoapyDirection.rx.rawValue,
            numericCast(channel),
            key
        ) else { return nil }
        defer { SoapySDR_free(ptr) }
        return String(cString: ptr)
    }
    
    func readTxChannelSensor(channel: Int, key: String) -> String? {
        guard let ptr = SoapySDRDevice_readChannelSensor(
            cDevice,
            SoapyDirection.tx.rawValue,
            numericCast(channel),
            key
        ) else { return nil }
        defer { SoapySDR_free(ptr) }
        return String(cString: ptr)
    }
    
    // --- Register API ---
    func registerInterfaces() -> [String] {
        var length: size_t = 0
        guard let list = SoapySDRDevice_listRegisterInterfaces(cDevice, &length) else { return [] }
        var result: [String] = []
        for i in 0..<Int(length) {
            if let ptr = list[i] {
                result.append(String(cString: ptr))
                SoapySDR_free(ptr)
            }
        }
        return result
    }
    
    func writeRegister(interface name: String, addr: UInt32, value: UInt32) -> Int {
        Int(SoapySDRDevice_writeRegister(cDevice, name, addr, value))
    }
    
    func readRegister(interface name: String, addr: UInt32) -> UInt32 {
        SoapySDRDevice_readRegister(cDevice, name, addr)
    }
    
    func writeRegisters(interface name: String, addr: UInt32, values: [UInt32]) -> Int {
        var valuesCopy = values
        return Int(valuesCopy.withUnsafeMutableBufferPointer {
            SoapySDRDevice_writeRegisters(
                cDevice,
                name,
                addr,
                $0.baseAddress,
                numericCast($0.count)
            )
        })
    }
    
    func readRegisters(interface name: String, addr: UInt32, count: Int) -> [UInt32] {
        var length: size_t = numericCast(count)
        guard let ptr = SoapySDRDevice_readRegisters(
            cDevice,
            name,
            addr,
            &length
        ) else { return [] }
        let buffer = UnsafeBufferPointer(start: ptr, count: Int(length))
        let result = Array(buffer)
        SoapySDR_free(ptr)
        return result
    }
    
    // --- Settings API ---
    func settingInfo() -> [SoapySDRArgInfo] {
        var length: size_t = 0
        guard let ptr = SoapySDRDevice_getSettingInfo(cDevice, &length) else { return [] }
        let buffer = UnsafeBufferPointer(start: ptr, count: Int(length))
        let info = Array(buffer)
        return info
    }
    
//    func settingInfo(key: String) -> SoapySDRArgInfo {
//        SoapySDRDevice_getSettingInfoWithKey(cDevice, key)
//    }
    
    func writeSetting(key: String, value: String) -> Int {
        Int(SoapySDRDevice_writeSetting(cDevice, key, value))
    }
    
    func readSetting(_ key: String) -> String? {
        guard let ptr = SoapySDRDevice_readSetting(cDevice, key) else { return nil }
        defer { SoapySDR_free(ptr) }
        return String(cString: ptr)
    }
    
    func rxChannelSettingInfo(channel: Int) -> [SoapySDRArgInfo] {
        var length: size_t = 0
        guard let ptr = SoapySDRDevice_getChannelSettingInfo(
            cDevice,
            SoapyDirection.rx.rawValue,
            numericCast(channel),
            &length
        ) else { return [] }
        let buffer = UnsafeBufferPointer(start: ptr, count: Int(length))
        let info = Array(buffer)
        return info
    }
    
    func txChannelSettingInfo(channel: Int) -> [SoapySDRArgInfo] {
        var length: size_t = 0
        guard let ptr = SoapySDRDevice_getChannelSettingInfo(
            cDevice,
            SoapyDirection.tx.rawValue,
            numericCast(channel),
            &length
        ) else { return [] }
        let buffer = UnsafeBufferPointer(start: ptr, count: Int(length))
        let info = Array(buffer)
        return info
    }
    
//    func rxChannelSettingInfo(channel: Int, key: String) -> SoapySDRArgInfo {
//        SoapySDRDevice_getChannelSettingInfoWithKey(
//            cDevice,
//            SoapyDirection.rx.rawValue,
//            numericCast(channel),
//            key
//        )
//    }
//    
//    func txChannelSettingInfo(channel: Int, key: String) -> SoapySDRArgInfo {
//        SoapySDRDevice_getChannelSettingInfoWithKey(
//            cDevice,
//            SoapyDirection.tx.rawValue,
//            numericCast(channel),
//            key
//        )
//    }
    
    func writeRxChannelSetting(channel: Int, key: String, value: String) -> Int {
        Int(SoapySDRDevice_writeChannelSetting(
            cDevice,
            SoapyDirection.rx.rawValue,
            numericCast(channel),
            key,
            value
        ))
    }
    
    func writeTxChannelSetting(channel: Int, key: String, value: String) -> Int {
        Int(SoapySDRDevice_writeChannelSetting(
            cDevice,
            SoapyDirection.tx.rawValue,
            numericCast(channel),
            key,
            value
        ))
    }
    
    func readRxChannelSetting(channel: Int, key: String) -> String? {
        guard let ptr = SoapySDRDevice_readChannelSetting(
            cDevice,
            SoapyDirection.rx.rawValue,
            numericCast(channel),
            key
        ) else { return nil }
        defer { SoapySDR_free(ptr) }
        return String(cString: ptr)
    }
    
    func readTxChannelSetting(channel: Int, key: String) -> String? {
        guard let ptr = SoapySDRDevice_readChannelSetting(
            cDevice,
            SoapyDirection.tx.rawValue,
            numericCast(channel),
            key
        ) else { return nil }
        defer { SoapySDR_free(ptr) }
        return String(cString: ptr)
    }
    
    // --- GPIO API ---
    func gpioBanks() -> [String] {
        var length: size_t = 0
        guard let list = SoapySDRDevice_listGPIOBanks(cDevice, &length) else { return [] }
        var result: [String] = []
        for i in 0..<Int(length) {
            if let ptr = list[i] {
                result.append(String(cString: ptr))
                SoapySDR_free(ptr)
            }
        }
        return result
    }
    
    func writeGPIO(bank: String, value: UInt32) -> Int {
        Int(SoapySDRDevice_writeGPIO(cDevice, bank, value))
    }
    
    func writeGPIOMasked(bank: String, value: UInt32, mask: UInt32) -> Int {
        Int(SoapySDRDevice_writeGPIOMasked(cDevice, bank, value, mask))
    }
    
    func readGPIO(bank: String) -> UInt32 {
        SoapySDRDevice_readGPIO(cDevice, bank)
    }
    
    func writeGPIODirection(bank: String, dir: UInt32) -> Int {
        Int(SoapySDRDevice_writeGPIODir(cDevice, bank, dir))
    }
    
    func writeGPIODirectionMasked(bank: String, dir: UInt32, mask: UInt32) -> Int {
        Int(SoapySDRDevice_writeGPIODirMasked(cDevice, bank, dir, mask))
    }
    
    func readGPIODirection(bank: String) -> UInt32 {
        SoapySDRDevice_readGPIODir(cDevice, bank)
    }
    
    // --- I2C API ---
    func writeI2C(addr: Int32, data: [UInt8]) -> Int {
        let mutable = data.map { Int8(bitPattern: $0) }
        return Int(mutable.withUnsafeBufferPointer {
            SoapySDRDevice_writeI2C(
                cDevice,
                addr,
                UnsafePointer($0.baseAddress),
                numericCast($0.count)
            )
        })
    }
    
    func readI2C(addr: Int32, numBytes: Int) -> [UInt8] {
        var length: size_t = numericCast(numBytes)
        guard let ptr = SoapySDRDevice_readI2C(cDevice, addr, &length) else { return [] }
        let buffer = UnsafeBufferPointer(start: ptr, count: Int(length))
        let result = buffer.map { UInt8(bitPattern: $0) }
        SoapySDR_free(ptr)
        return result
    }
    
    // --- SPI API ---
    func transactSPI(addr: Int32, data: UInt32, numBits: Int) -> UInt32 {
        SoapySDRDevice_transactSPI(cDevice, addr, data, numericCast(numBits))
    }
    
    // --- UART API ---
    func uarts() -> [String] {
        var length: size_t = 0
        guard let list = SoapySDRDevice_listUARTs(cDevice, &length) else { return [] }
        var result: [String] = []
        for i in 0..<Int(length) {
            if let ptr = list[i] {
                result.append(String(cString: ptr))
                SoapySDR_free(ptr)
            }
        }
        return result
    }
    
    func writeUART(which: String, data: String) -> Int {
        Int(SoapySDRDevice_writeUART(cDevice, which, data))
    }
    
    func readUART(which: String, timeoutUs: Int) -> String? {
        guard let ptr = SoapySDRDevice_readUART(cDevice, which, timeoutUs) else { return nil }
        defer { SoapySDR_free(ptr) }
        return String(cString: ptr)
    }
    
    // --- Native Handle ---
    var nativeHandle: UnsafeMutableRawPointer? {
        SoapySDRDevice_getNativeDeviceHandle(cDevice)
    }
    
    var description: String {
        var output = "--- SoapyDevice: \(self.driverName ?? "Unknown") (\(self.hardwareName ?? "Unknown")) ---\n\n"
        
        output += "[METADATA]\n"
        output += "Hardware Kwargs: \(self.hardwareKwargs.description)\n\n"
        
        output += "[CHANNELS]\n"
        output += "RX: \(self.rxNumChannels) | TX: \(self.txNumChannels)\n\n"

        func buildChannelString(isRx: Bool, channel: Int) -> String {
            var str = ""
            // --- General Info ---
            let info = isRx ? self.rxChannelInfo(channel: channel) : self.txChannelInfo(channel: channel)
            let isDuplex = isRx ? self.rxIsFullDuplex(channel: channel) : self.txIsFullDuplex(channel: channel)
            let antennas = isRx ? self.rxAntennas(channel: channel) : self.txAntennas(channel: channel)
            
            if !info.description.isEmpty && info.description != "SoapyKwargs: empty" {
                str += "  Info:         \(info.description)\n"
            }
            str += "  Antenna:      \(antennas.joined(separator: ", "))\n"
            str += "  Full Duplex:  \(isDuplex)\n\n"

            // --- Frequencies ---
            str += "  -- Frequency --\n"
            let currentFreq = isRx ? self.rxFrequency(channel: channel) : self.txFrequency(channel: channel)
            let ranges = isRx ? self.rxFrequencyRange(channel: channel) : self.txFrequencyRange(channel: channel)
            
            str += "  Current:      \(Frequency(hz: currentFreq).description(unit: .mhz))\n"
            str += "  Range:        \(ranges.map { $0.descriptionWithFrequencyUnits }.joined(separator: " / "))\n"
            
            let components = isRx ? self.rxFrequencyElements(channel: channel) : self.txFrequencyElements(channel: channel)
            if !components.isEmpty {
                str += "  Tunable Elements:\n"
                let elementDict: [String: String] = ["CORR": "Correction", "RF": "RF Frontend", "BB": "Baseband"]
                
                for comp in components {
                    let compFreq = isRx ? self.rxFrequencyComponent(channel: channel, name: comp) : self.txFrequencyComponent(channel: channel, name: comp)
                    let compRanges = isRx ? self.rxFrequencyRange(channel: channel, element: comp) : self.txFrequencyRange(channel: channel, element: comp)
                    let prettyName = elementDict[comp] ?? comp
                    
                    str += "    * \(prettyName): \(compFreq)\n"
                    str += "      (Range: \(compRanges.map { $0.description }.joined(separator: ", ")))\n"
                }
            }
            str += "\n"

            // --- Gain ---
            str += "  -- Gain --\n"
            let hasAgc = isRx ? self.rxHasGainMode(channel: channel) : self.txHasGainMode(channel: channel)
            let agcEnabled = isRx ? self.rxGainMode(channel: channel) : self.txGainMode(channel: channel)
            let totalGain = isRx ? self.rxGain(channel: channel) : self.txGain(channel: channel)
            let totalRange = isRx ? self.rxGainRange(channel: channel) : self.txGainRange(channel: channel)
            
            str += "  Mode:         \(hasAgc ? (agcEnabled ? "Automatic" : "Manual (AGC Supported)") : "Manual Only")\n"
            str += "  Total Gain:   \(totalGain) (Range: \(totalRange.description))\n"
            
            let gainElements = isRx ? self.rxGainElements(channel: channel) : self.txGainElements(channel: channel)
            if !gainElements.isEmpty {
                str += "  Elements:\n"
                for element in gainElements {
                    let elGain = isRx ? self.rxGain(channel: channel, element: element) : self.txGain(channel: channel, element: element)
                    let elRange = isRx ? self.rxGainElementRange(channel: channel, element: element) : self.txGainElementRange(channel: channel, element: element)
                    str += "    * \(element): \(elGain) (Range: \(elRange.description))\n"
                }
            }
            str += "\n"

            // --- Sample Rate & Bandwidth ---
            str += "  -- Sample Rate & Bandwidth --\n"
            let rate = isRx ? self.rxSampleRate(channel: channel) : self.txSampleRate(channel: channel)
            let bw = isRx ? self.rxBandwidth(channel: channel) : self.txBandwidth(channel: channel)
            let rateRanges = isRx ? self.rxSampleRateRanges(channel: channel) : self.txSampleRateRanges(channel: channel)
            let bwRanges = isRx ? self.rxBandwidthRanges(channel: channel) : self.txBandwidthRanges(channel: channel)
            
            str += "  Rate:         \(rate)\n"
            str += "  Bandwidth:    \(Frequency(hz:bw).description(unit: .mhz)) (Range: \(bwRanges.map { $0.descriptionWithFrequencyUnits }.joined(separator: ", ")))\n"
            str += "  Supported Rates:\n"
            for range in rateRanges {
                str += "    * \(range.description)\n"
            }
            str += "\n"

            // --- Corrections ---
            str += "  -- Corrections --\n"
            
            // DC Offset
            let hasDC = isRx ? self.rxHasDCOffset(channel: channel) : self.txHasDCOffset(channel: channel)
            if hasDC {
                let dcVal = isRx ? self.rxDCOffset(channel: channel) : self.txDCOffset(channel: channel)
                let autoDC = isRx ? self.rxDCOffsetMode(channel: channel) : self.txDCOffsetMode(channel: channel)
                str += "  DC Offset:    \(autoDC ? "Automatic" : "Manual") -> \(String(describing: dcVal))\n"
            } else {
                str += "  DC Offset:    Not Supported\n"
            }
            
            // IQ Balance
            let hasIQ = isRx ? self.rxHasIQBalance(channel: channel) : self.txHasIQBalance(channel: channel)
            if hasIQ {
                let iqVal = isRx ? self.rxIQBalance(channel: channel) : self.txIQBalance(channel: channel)
                let autoIQ = isRx ? self.rxIQBalanceMode(channel: channel) : self.txIQBalanceMode(channel: channel)
                str += "  IQ Balance:   \(autoIQ ? "Automatic" : "Manual") -> \(String(describing: iqVal))\n"
            } else {
                str += "  IQ Balance:   Not Supported\n"
            }
            
            return str
        }
        
        for rxChannel in 0..<self.rxNumChannels {
            output += "[RX CHANNEL \(rxChannel)]\n"
            output += buildChannelString(isRx: true, channel: rxChannel)
            output += "\n"
        }
        
        for txChannel in 0..<self.txNumChannels {
            output += "[TX CHANNEL \(txChannel)]\n"
            output += buildChannelString(isRx: false, channel: txChannel)
            output += "\n"
        }

        output += "--------------------------------"
        return output
    }
    
    // --- Init / Deinit ---
    init(kwargs: SoapyKwargs) throws {
        let cKwargPointer = kwargs.getcKwargsMutablePointer()
        defer { cKwargPointer.deallocate() }
        
        guard let devicePtr = SoapySDRDevice_make(cKwargPointer) else {
            print("SoapySDRWrapper: Failed to create SoapySDRDevice.")
            throw SoapySDRWrapperErrors.deviceInitFailed
        }
        self.cDevice = devicePtr
        
        if deviceCache.deviceIsPresent(devicePtr) {
            print("SoapySDRWrapper warning: Device already present in cache, this SoapyDevice will refer to the same SDR as an existing SoapyDevice.")
        }
        deviceCache.addDevice(devicePtr)
    }
    
    deinit {
        deviceCache.removeDevice(cDevice)
        SoapySDRDevice_unmake(cDevice)
    }
}

// --- Global Device Status Helpers ---
extension SoapyDevice {
    static var lastStatus: Int {
        Int(SoapySDRDevice_lastStatus())
    }
    
    static var lastError: String? {
        guard let ptr = SoapySDRDevice_lastError() else { return nil }
        // Do NOT free lastError, it is internal thread-local storage.
        return String(cString: ptr)
    }
}
