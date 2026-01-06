//
//  Gain.swift
//  SoapySDRWrapper
//
//  Created by Connor Gibbons  on 12/3/25.
//

import CSoapySDR

extension SoapyDevice {
    
    // --- Gain API ---
    func gainElements(direction: SoapyDirection, channel: Int) -> [String] {
        var length: size_t = 0
        guard let list = SoapySDRDevice_listGains(
            cDevice,
            direction.rawValue,
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
    
    func hasGainMode(direction: SoapyDirection, channel: Int) -> Bool {
        SoapySDRDevice_hasGainMode(cDevice, direction.rawValue, numericCast(channel))
    }
    
    @discardableResult
    func setGainMode(direction: SoapyDirection, channel: Int, automatic: Bool) -> Int {
        Int(SoapySDRDevice_setGainMode(
            cDevice,
            direction.rawValue,
            numericCast(channel),
            automatic
        ))
    }
    
    func gainMode(direction: SoapyDirection, channel: Int) -> Bool {
        SoapySDRDevice_getGainMode(cDevice, direction.rawValue, numericCast(channel))
    }
    
    @discardableResult
    func setGain(direction: SoapyDirection, channel: Int, value: Double) -> Int {
        Int(SoapySDRDevice_setGain(
            cDevice,
            direction.rawValue,
            numericCast(channel),
            value
        ))
    }
    
    @discardableResult
    func setGain(direction: SoapyDirection, channel: Int, element name: String, value: Double) -> Int {
        Int(SoapySDRDevice_setGainElement(
            cDevice,
            direction.rawValue,
            numericCast(channel),
            name,
            value
        ))
    }
    
    func gain(direction: SoapyDirection, channel: Int) -> Double {
        SoapySDRDevice_getGain(cDevice, direction.rawValue, numericCast(channel))
    }
    
    func gain(direction: SoapyDirection, channel: Int, element name: String) -> Double {
        SoapySDRDevice_getGainElement(
            cDevice,
            direction.rawValue,
            numericCast(channel),
            name
        )
    }
    
    func gainRange(direction: SoapyDirection, channel: Int) -> SoapySDRRange {
        SoapySDRDevice_getGainRange(cDevice, direction.rawValue, numericCast(channel))
    }
    
    func gainElementRange(direction: SoapyDirection, channel: Int, element name: String) -> SoapySDRRange {
        SoapySDRDevice_getGainElementRange(
            cDevice,
            direction.rawValue,
            numericCast(channel),
            name
        )
    }
    
}
