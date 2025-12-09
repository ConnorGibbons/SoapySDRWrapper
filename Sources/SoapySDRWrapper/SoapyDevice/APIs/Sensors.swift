//
//  Sensors.swift
//  SoapySDRWrapper
//
//  Created by Connor Gibbons  on 12/3/25.
//

import CSoapySDR

extension SoapyDevice {
    
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
    
}
