//
//  Gain.swift
//  SoapySDRWrapper
//
//  Created by Connor Gibbons  on 12/3/25.
//

import CSoapySDR

extension SoapyDevice {

    // --- Gain API ---
    public func gainElements(direction: SoapyDirection, channel: Int) -> [String] {
        queue.sync {
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
    }

    public func hasGainMode(direction: SoapyDirection, channel: Int) -> Bool {
        queue.sync {
            SoapySDRDevice_hasGainMode(cDevice, direction.rawValue, numericCast(channel))
        }
    }

    public func setGainMode(direction: SoapyDirection, channel: Int, automatic: Bool) throws {
        try queue.sync {
            try SoapySDRMaybeThrowError(code: SoapySDRDevice_setGainMode(
                cDevice,
                direction.rawValue,
                numericCast(channel),
                automatic
            ))
        }
    }

    public func gainMode(direction: SoapyDirection, channel: Int) -> Bool {
        queue.sync {
            SoapySDRDevice_getGainMode(cDevice, direction.rawValue, numericCast(channel))
        }
    }

    public func setGain(direction: SoapyDirection, channel: Int, value: Double) throws {
        try queue.sync {
            try SoapySDRMaybeThrowError(code: SoapySDRDevice_setGain(
                cDevice,
                direction.rawValue,
                numericCast(channel),
                value
            ))
        }
    }

    public func setGain(direction: SoapyDirection, channel: Int, element name: String, value: Double) throws {
        try queue.sync {
            try SoapySDRMaybeThrowError(code: SoapySDRDevice_setGainElement(
                cDevice,
                direction.rawValue,
                numericCast(channel),
                name,
                value
            ))
        }
    }

    public func gain(direction: SoapyDirection, channel: Int) -> Double {
        queue.sync {
            SoapySDRDevice_getGain(cDevice, direction.rawValue, numericCast(channel))
        }
    }

    public func gain(direction: SoapyDirection, channel: Int, element name: String) -> Double {
        queue.sync {
            SoapySDRDevice_getGainElement(
                cDevice,
                direction.rawValue,
                numericCast(channel),
                name
            )
        }
    }

    public func gainRange(direction: SoapyDirection, channel: Int) -> SoapySDRRange {
        queue.sync {
            SoapySDRDevice_getGainRange(cDevice, direction.rawValue, numericCast(channel))
        }
    }

    public func gainElementRange(direction: SoapyDirection, channel: Int, element name: String) -> SoapySDRRange {
        queue.sync {
            SoapySDRDevice_getGainElementRange(
                cDevice,
                direction.rawValue,
                numericCast(channel),
                name
            )
        }
    }

}
