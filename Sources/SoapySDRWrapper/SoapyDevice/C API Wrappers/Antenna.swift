//
//  Antenna.swift
//  SoapySDRWrapper
//
//  Created by Connor Gibbons  on 12/3/25.
//

import CSoapySDR

extension SoapyDevice {
    
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
    
}
