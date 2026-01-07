//
//  Sensors.swift
//  SoapySDRWrapper
//
//  Created by Connor Gibbons  on 12/3/25.
//

import CSoapySDR

extension SoapyDevice {

    // --- Sensor API ---
    public func sensors() -> [String] {
        queue.sync {
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
    }

    public func sensorInfo(_ key: String) -> SoapySDRArgInfo {
        queue.sync {
            SoapySDRDevice_getSensorInfo(cDevice, key)
        }
    }

    public func readSensor(_ key: String) -> String? {
        queue.sync {
            guard let ptr = SoapySDRDevice_readSensor(cDevice, key) else { return nil }
            defer { SoapySDR_free(ptr) }
            return String(cString: ptr)
        }
    }

    public func channelSensors(direction: SoapyDirection, channel: Int) -> [String] {
        queue.sync {
            var length: size_t = 0
            guard let list = SoapySDRDevice_listChannelSensors(
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
    }

    public func channelSensorInfo(direction: SoapyDirection, channel: Int, key: String) -> SoapySDRArgInfo {
        queue.sync {
            SoapySDRDevice_getChannelSensorInfo(
                cDevice,
                direction.rawValue,
                numericCast(channel),
                key
            )
        }
    }

    public func readChannelSensor(direction: SoapyDirection, channel: Int, key: String) -> String? {
        queue.sync {
            guard let ptr = SoapySDRDevice_readChannelSensor(
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
