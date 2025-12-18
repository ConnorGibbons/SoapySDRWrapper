//
//  Gain.swift
//  SoapySDRWrapper
//
//  Created by Connor Gibbons  on 12/3/25.
//

import CSoapySDR

extension SoapyDevice {
    
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
    
}
