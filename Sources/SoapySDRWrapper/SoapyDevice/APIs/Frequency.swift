//
//  Frequency.swift
//  SoapySDRWrapper
//
//  Created by Connor Gibbons  on 12/3/25.
//

import CSoapySDR

extension SoapyDevice {
    
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
    
}
