//
//  Antenna.swift
//  SoapySDRWrapper
//
//  Created by Connor Gibbons  on 12/3/25.
//

import CSoapySDR

extension SoapyDevice {
    
    // --- Antenna API ---
    func antennas(direction: SoapyDirection, channel: Int) -> [String] {
        var length: size_t = 0
        guard let list = SoapySDRDevice_listAntennas(
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
    
    @discardableResult
    func setAntenna(direction: SoapyDirection, channel: Int, name: String) -> Int {
        Int(SoapySDRDevice_setAntenna(
            cDevice,
            direction.rawValue,
            numericCast(channel),
            name
        ))
    }
    
    func antenna(direction: SoapyDirection, channel: Int) -> String? {
        guard let ptr = SoapySDRDevice_getAntenna(
            cDevice,
            direction.rawValue,
            numericCast(channel)
        ) else { return nil }
        defer { SoapySDR_free(ptr) }
        return String(cString: ptr)
    }
    
}
