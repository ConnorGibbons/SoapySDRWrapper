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
    func hasDCOffsetMode(direction: SoapyDirection, channel: Int) -> Bool {
        SoapySDRDevice_hasDCOffsetMode(cDevice, direction.rawValue, numericCast(channel))
    }
    
    @discardableResult
    func setDCOffsetMode(direction: SoapyDirection, channel: Int, automatic: Bool) -> Int {
        Int(SoapySDRDevice_setDCOffsetMode(
            cDevice,
            direction.rawValue,
            numericCast(channel),
            automatic
        ))
    }
    
    func dcOffsetMode(direction: SoapyDirection, channel: Int) -> Bool {
        SoapySDRDevice_getDCOffsetMode(cDevice, direction.rawValue, numericCast(channel))
    }
    
    func hasDCOffset(direction: SoapyDirection, channel: Int) -> Bool {
        SoapySDRDevice_hasDCOffset(cDevice, direction.rawValue, numericCast(channel))
    }
    
    @discardableResult
    func setDCOffset(direction: SoapyDirection, channel: Int, offsetI: Double, offsetQ: Double) -> Int {
        Int(SoapySDRDevice_setDCOffset(
            cDevice,
            direction.rawValue,
            numericCast(channel),
            offsetI,
            offsetQ
        ))
    }
    
    func dcOffset(direction: SoapyDirection, channel: Int) -> (offsetI: Double, offsetQ: Double)? {
        var i: Double = 0
        var q: Double = 0
        let status = SoapySDRDevice_getDCOffset(
            cDevice,
            direction.rawValue,
            numericCast(channel),
            &i,
            &q
        )
        guard status == 0 else { return nil }
        return (i, q)
    }
    
    func hasIQBalance(direction: SoapyDirection, channel: Int) -> Bool {
        SoapySDRDevice_hasIQBalance(cDevice, direction.rawValue, numericCast(channel))
    }
    
    @discardableResult
    func setIQBalance(direction: SoapyDirection, channel: Int, balanceI: Double, balanceQ: Double) -> Int {
        Int(SoapySDRDevice_setIQBalance(
            cDevice,
            direction.rawValue,
            numericCast(channel),
            balanceI,
            balanceQ
        ))
    }
    
    func iqBalance(direction: SoapyDirection, channel: Int) -> (balanceI: Double, balanceQ: Double)? {
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
    
    func hasIQBalanceMode(direction: SoapyDirection, channel: Int) -> Bool {
        SoapySDRDevice_hasIQBalanceMode(cDevice, direction.rawValue, numericCast(channel))
    }
    
    @discardableResult
    func setIQBalanceMode(direction: SoapyDirection, channel: Int, automatic: Bool) -> Int {
        Int(SoapySDRDevice_setIQBalanceMode(
            cDevice,
            direction.rawValue,
            numericCast(channel),
            automatic
        ))
    }
    
    func iqBalanceMode(direction: SoapyDirection, channel: Int) -> Bool {
        SoapySDRDevice_getIQBalanceMode(cDevice, direction.rawValue, numericCast(channel))
    }
    
    func hasFrequencyCorrection(direction: SoapyDirection, channel: Int) -> Bool {
        SoapySDRDevice_hasFrequencyCorrection(cDevice, direction.rawValue, numericCast(channel))
    }
    
    @discardableResult
    func setFrequencyCorrection(direction: SoapyDirection, channel: Int, ppm: Double) -> Int {
        Int(SoapySDRDevice_setFrequencyCorrection(
            cDevice,
            direction.rawValue,
            numericCast(channel),
            ppm
        ))
    }
    
    func frequencyCorrection(direction: SoapyDirection, channel: Int) -> Double {
        SoapySDRDevice_getFrequencyCorrection(cDevice, direction.rawValue, numericCast(channel))
    }
    
}
