//
//  Settings.swift
//  SoapySDRWrapper
//
//  Created by Connor Gibbons  on 12/3/25.
//

import CSoapySDR

extension SoapyDevice {

    // --- Settings API ---
    public func settingInfo() -> [SoapySDRArgInfo] {
        queue.sync {
            var length: size_t = 0
            guard let ptr = SoapySDRDevice_getSettingInfo(cDevice, &length) else { return [] }
            let buffer = UnsafeBufferPointer(start: ptr, count: Int(length))
            let info = Array(buffer)
            return info
        }
    }

//    func settingInfo(key: String) -> SoapySDRArgInfo {
//        SoapySDRDevice_getSettingInfoWithKey(cDevice, key)
//    }

    public func writeSetting(key: String, value: String) -> Int {
        queue.sync {
            Int(SoapySDRDevice_writeSetting(cDevice, key, value))
        }
    }

    public func readSetting(_ key: String) -> String? {
        queue.sync {
            guard let ptr = SoapySDRDevice_readSetting(cDevice, key) else { return nil }
            defer { SoapySDR_free(ptr) }
            return String(cString: ptr)
        }
    }

    public func channelSettingInfo(direction: SoapyDirection, channel: Int) -> [SoapySDRArgInfo] {
        queue.sync {
            var length: size_t = 0
            guard let ptr = SoapySDRDevice_getChannelSettingInfo(
                cDevice,
                direction.rawValue,
                numericCast(channel),
                &length
            ) else { return [] }
            let buffer = UnsafeBufferPointer(start: ptr, count: Int(length))
            let info = Array(buffer)
            return info
        }
    }

    public func writeChannelSetting(direction: SoapyDirection, channel: Int, key: String, value: String) -> Int {
        queue.sync {
            Int(SoapySDRDevice_writeChannelSetting(
                cDevice,
                direction.rawValue,
                numericCast(channel),
                key,
                value
            ))
        }
    }

    public func readChannelSetting(direction: SoapyDirection, channel: Int, key: String) -> String? {
        queue.sync {
            guard let ptr = SoapySDRDevice_readChannelSetting(
                cDevice,
                direction.rawValue,
                numericCast(channel),
                key
            ) else { return nil }
            defer { SoapySDR_free(ptr) }
            return String(cString: ptr)
        }
    }

}
