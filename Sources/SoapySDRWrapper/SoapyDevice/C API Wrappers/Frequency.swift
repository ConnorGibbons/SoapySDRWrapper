//
//  Frequency.swift
//  SoapySDRWrapper
//
//  Created by Connor Gibbons  on 12/3/25.
//

import CSoapySDR

extension SoapyDevice {

    // --- Frequency API ---
    public func setFrequency(direction: SoapyDirection, channel: Int, frequency: Double, args: SoapyKwargs? = nil) throws {
        try queue.sync {
            if var cArgs = args?.cKwargs {
                try soapySDR_errToThrow(code: SoapySDRDevice_setFrequency(
                    cDevice,
                    direction.rawValue,
                    numericCast(channel),
                    frequency,
                    &cArgs
                ))
            } else {
                try soapySDR_errToThrow(code: SoapySDRDevice_setFrequency(
                    cDevice,
                    direction.rawValue,
                    numericCast(channel),
                    frequency,
                    nil
                ))
            }
        }
    }

    public func setFrequencyComponent(direction: SoapyDirection, channel: Int, name: String, frequency: Double, args: SoapyKwargs? = nil) throws {
        try queue.sync {
            if var cArgs = args?.cKwargs {
                try soapySDR_errToThrow(code: SoapySDRDevice_setFrequencyComponent(
                    cDevice,
                    direction.rawValue,
                    numericCast(channel),
                    name,
                    frequency,
                    &cArgs
                ))
            } else {
                try soapySDR_errToThrow(code: SoapySDRDevice_setFrequencyComponent(
                    cDevice,
                    direction.rawValue,
                    numericCast(channel),
                    name,
                    frequency,
                    nil
                ))
            }
        }
    }

    public func frequency(direction: SoapyDirection, channel: Int) -> Double {
        queue.sync {
            SoapySDRDevice_getFrequency(cDevice, direction.rawValue, numericCast(channel))
        }
    }

    public func frequencyComponent(direction: SoapyDirection, channel: Int, name: String) -> Double {
        queue.sync {
            SoapySDRDevice_getFrequencyComponent(
                cDevice,
                direction.rawValue,
                numericCast(channel),
                name
            )
        }
    }

    public func frequencyElements(direction: SoapyDirection, channel: Int) -> [String] {
        queue.sync {
            var length: size_t = 0
            guard let list = SoapySDRDevice_listFrequencies(
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

    public func frequencyRange(direction: SoapyDirection, channel: Int) -> [SoapySDRRange] {
        queue.sync {
            var length: size_t = 0
            guard let ptr = SoapySDRDevice_getFrequencyRange(
                cDevice,
                direction.rawValue,
                numericCast(channel),
                &length
            ) else { return [] }

            let buffer = UnsafeBufferPointer(start: ptr, count: Int(length))
            let ranges = Array(buffer)
            SoapySDR_free(ptr)
            return ranges
        }
    }

    public func frequencyRange(direction: SoapyDirection, channel: Int, element name: String) -> [SoapySDRRange] {
        queue.sync {
            var length: size_t = 0
            guard let ptr = SoapySDRDevice_getFrequencyRangeComponent(
                cDevice,
                direction.rawValue,
                numericCast(channel),
                name,
                &length
            ) else { return [] }

            let buffer = UnsafeBufferPointer(start: ptr, count: Int(length))
            let ranges = Array(buffer)
            SoapySDR_free(ptr)
            return ranges
        }
    }

    public func frequencyArgsInfo(direction: SoapyDirection, channel: Int) -> [SoapySDRArgInfo] {
        queue.sync {
            var length: size_t = 0
            guard let ptr = SoapySDRDevice_getFrequencyArgsInfo(
                cDevice,
                direction.rawValue,
                numericCast(channel),
                &length
            ) else { return [] }
            let buffer = UnsafeBufferPointer(start: ptr, count: Int(length))
            let info = Array(buffer)
            // ArgInfoList_clear would invalidate copied structs; leak is preferable here.
            return info
        }
    }

}
