//
//  Corrections.swift
//  SoapySDRWrapper
//
//  Created by Connor Gibbons  on 12/3/25.
//

import CSoapySDR

extension SoapyDevice {

    // --- Frontend Corrections API ---

    /// Returns 'true' if automatic DC offset mode is supported by the device for this channel.
    public func hasDCOffsetMode(direction: SoapyDirection, channel: Int) -> Bool {
        queue.sync {
            SoapySDRDevice_hasDCOffsetMode(cDevice, direction.rawValue, numericCast(channel))
        }
    }

    public func setDCOffsetMode(direction: SoapyDirection, channel: Int, automatic: Bool) throws {
        try queue.sync {
            try SoapySDRMaybeThrowError(code: SoapySDRDevice_setDCOffsetMode(
                cDevice,
                direction.rawValue,
                numericCast(channel),
                automatic
            ))
        }
    }

    public func dcOffsetMode(direction: SoapyDirection, channel: Int) -> Bool {
        queue.sync {
            SoapySDRDevice_getDCOffsetMode(cDevice, direction.rawValue, numericCast(channel))
        }
    }

    public func hasDCOffset(direction: SoapyDirection, channel: Int) -> Bool {
        queue.sync {
            SoapySDRDevice_hasDCOffset(cDevice, direction.rawValue, numericCast(channel))
        }
    }

    public func setDCOffset(direction: SoapyDirection, channel: Int, offsetI: Double, offsetQ: Double) throws {
        try queue.sync {
            try SoapySDRMaybeThrowError(code: SoapySDRDevice_setDCOffset(
                cDevice,
                direction.rawValue,
                numericCast(channel),
                offsetI,
                offsetQ
            ))
        }
    }

    public func dcOffset(direction: SoapyDirection, channel: Int) throws -> (offsetI: Double, offsetQ: Double) {
        try queue.sync {
            var i: Double = 0
            var q: Double = 0
            let status = SoapySDRDevice_getDCOffset(
                cDevice,
                direction.rawValue,
                numericCast(channel),
                &i,
                &q
            )
            try SoapySDRMaybeThrowError(code: status)
            return (i, q)
        }
    }

    public func hasIQBalance(direction: SoapyDirection, channel: Int) -> Bool {
        queue.sync {
            SoapySDRDevice_hasIQBalance(cDevice, direction.rawValue, numericCast(channel))
        }
    }

    public func setIQBalance(direction: SoapyDirection, channel: Int, balanceI: Double, balanceQ: Double) throws {
        try queue.sync {
            try SoapySDRMaybeThrowError(code: SoapySDRDevice_setIQBalance(
                cDevice,
                direction.rawValue,
                numericCast(channel),
                balanceI,
                balanceQ
            ))
        }
    }

    public func iqBalance(direction: SoapyDirection, channel: Int) -> (balanceI: Double, balanceQ: Double)? {
        queue.sync {
            var i: Double = 0
            var q: Double = 0
            let status = SoapySDRDevice_getIQBalance(
                cDevice,
                direction.rawValue,
                numericCast(channel),
                &i,
                &q
            )
            guard status == 0 else { return nil }
            return (i, q)
        }
    }

    public func hasIQBalanceMode(direction: SoapyDirection, channel: Int) -> Bool {
        queue.sync {
            SoapySDRDevice_hasIQBalanceMode(cDevice, direction.rawValue, numericCast(channel))
        }
    }

    public func setIQBalanceMode(direction: SoapyDirection, channel: Int, automatic: Bool) throws {
        try queue.sync {
            try SoapySDRMaybeThrowError(code: SoapySDRDevice_setIQBalanceMode(
                cDevice,
                direction.rawValue,
                numericCast(channel),
                automatic
            ))
        }
    }

    public func iqBalanceMode(direction: SoapyDirection, channel: Int) -> Bool {
        queue.sync {
            SoapySDRDevice_getIQBalanceMode(cDevice, direction.rawValue, numericCast(channel))
        }
    }

    public func hasFrequencyCorrection(direction: SoapyDirection, channel: Int) -> Bool {
        queue.sync {
            SoapySDRDevice_hasFrequencyCorrection(cDevice, direction.rawValue, numericCast(channel))
        }
    }

    public func setFrequencyCorrection(direction: SoapyDirection, channel: Int, ppm: Double) throws {
        try queue.sync {
            try SoapySDRMaybeThrowError(code: SoapySDRDevice_setFrequencyCorrection(
                cDevice,
                direction.rawValue,
                numericCast(channel),
                ppm
            ))
        }
    }

    public func frequencyCorrection(direction: SoapyDirection, channel: Int) -> Double {
        queue.sync {
            SoapySDRDevice_getFrequencyCorrection(cDevice, direction.rawValue, numericCast(channel))
        }
    }

}
