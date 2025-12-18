//
//  Settings.swift
//  SoapySDRWrapper
//
//  Created by Connor Gibbons  on 12/3/25.
//

import CSoapySDR

extension SoapyDevice {
    
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
  
}
