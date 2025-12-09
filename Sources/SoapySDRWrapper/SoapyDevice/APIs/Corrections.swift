//
//  Corrections.swift
//  SoapySDRWrapper
//
//  Created by Connor Gibbons  on 12/3/25.
//

import CSoapySDR

extension SoapyDevice {
    
    // --- Frontend Corrections API ---
    
    /// Returns 'true' if automatic DC offset mode is supported by the device for this RX channel.
    func rxHasDCOffsetMode(channel: Int) -> Bool {
        SoapySDRDevice_hasDCOffsetMode(cDevice, SoapyDirection.rx.rawValue, numericCast(channel))
    }
    
    /// Returns 'true' if automatic DC offset mode is supported by the device for this TX channel.
    func txHasDCOffsetMode(channel: Int) -> Bool {
        SoapySDRDevice_hasDCOffsetMode(cDevice, SoapyDirection.tx.rawValue, numericCast(channel))
    }
    
    @discardableResult
    func setRxDCOffsetMode(channel: Int, automatic: Bool) -> Int {
        Int(SoapySDRDevice_setDCOffsetMode(
            cDevice,
            SoapyDirection.rx.rawValue,
            numericCast(channel),
            automatic
        ))
    }
    
    @discardableResult
    func setTxDCOffsetMode(channel: Int, automatic: Bool) -> Int {
        Int(SoapySDRDevice_setDCOffsetMode(
            cDevice,
            SoapyDirection.tx.rawValue,
            numericCast(channel),
            automatic
        ))
    }
    
    func rxDCOffsetMode(channel: Int) -> Bool {
        SoapySDRDevice_getDCOffsetMode(cDevice, SoapyDirection.rx.rawValue, numericCast(channel))
    }
    
    func txDCOffsetMode(channel: Int) -> Bool {
        SoapySDRDevice_getDCOffsetMode(cDevice, SoapyDirection.tx.rawValue, numericCast(channel))
    }
    
    func rxHasDCOffset(channel: Int) -> Bool {
        SoapySDRDevice_hasDCOffset(cDevice, SoapyDirection.rx.rawValue, numericCast(channel))
    }
    
    func txHasDCOffset(channel: Int) -> Bool {
        SoapySDRDevice_hasDCOffset(cDevice, SoapyDirection.tx.rawValue, numericCast(channel))
    }
    
    @discardableResult
    func setRxDCOffset(channel: Int, offsetI: Double, offsetQ: Double) -> Int {
        Int(SoapySDRDevice_setDCOffset(
            cDevice,
            SoapyDirection.rx.rawValue,
            numericCast(channel),
            offsetI,
            offsetQ
        ))
    }
    
    @discardableResult
    func setTxDCOffset(channel: Int, offsetI: Double, offsetQ: Double) -> Int {
        Int(SoapySDRDevice_setDCOffset(
            cDevice,
            SoapyDirection.tx.rawValue,
            numericCast(channel),
            offsetI,
            offsetQ
        ))
    }
    
    func rxDCOffset(channel: Int) -> (offsetI: Double, offsetQ: Double)? {
        var i: Double = 0
        var q: Double = 0
        let status = SoapySDRDevice_getDCOffset(
            cDevice,
            SoapyDirection.rx.rawValue,
            numericCast(channel),
            &i,
            &q
        )
        guard status == 0 else { return nil }
        return (i, q)
    }
    
    func txDCOffset(channel: Int) -> (offsetI: Double, offsetQ: Double)? {
        var i: Double = 0
        var q: Double = 0
        let status = SoapySDRDevice_getDCOffset(
            cDevice,
            SoapyDirection.tx.rawValue,
            numericCast(channel),
            &i,
            &q
        )
        guard status == 0 else { return nil }
        return (i, q)
    }
    
    func rxHasIQBalance(channel: Int) -> Bool {
        SoapySDRDevice_hasIQBalance(cDevice, SoapyDirection.rx.rawValue, numericCast(channel))
    }
    
    func txHasIQBalance(channel: Int) -> Bool {
        SoapySDRDevice_hasIQBalance(cDevice, SoapyDirection.tx.rawValue, numericCast(channel))
    }
    
    @discardableResult
    func setRxIQBalance(channel: Int, balanceI: Double, balanceQ: Double) -> Int {
        Int(SoapySDRDevice_setIQBalance(
            cDevice,
            SoapyDirection.rx.rawValue,
            numericCast(channel),
            balanceI,
            balanceQ
        ))
    }
    
    @discardableResult
    func setTxIQBalance(channel: Int, balanceI: Double, balanceQ: Double) -> Int {
        Int(SoapySDRDevice_setIQBalance(
            cDevice,
            SoapyDirection.tx.rawValue,
            numericCast(channel),
            balanceI,
            balanceQ
        ))
    }
    
    func rxIQBalance(channel: Int) -> (balanceI: Double, balanceQ: Double)? {
        var i: Double = 0
        var q: Double = 0
        let status = SoapySDRDevice_getIQBalance(
            cDevice,
            SoapyDirection.rx.rawValue,
            numericCast(channel),
            &i,
            &q
        )
        guard status == 0 else { return nil }
        return (i, q)
    }
    
    func txIQBalance(channel: Int) -> (balanceI: Double, balanceQ: Double)? {
        var i: Double = 0
        var q: Double = 0
        let status = SoapySDRDevice_getIQBalance(
            cDevice,
            SoapyDirection.tx.rawValue,
            numericCast(channel),
            &i,
            &q
        )
        guard status == 0 else { return nil }
        return (i, q)
    }
    
    func rxHasIQBalanceMode(channel: Int) -> Bool {
        SoapySDRDevice_hasIQBalanceMode(cDevice, SoapyDirection.rx.rawValue, numericCast(channel))
    }
    
    func txHasIQBalanceMode(channel: Int) -> Bool {
        SoapySDRDevice_hasIQBalanceMode(cDevice, SoapyDirection.tx.rawValue, numericCast(channel))
    }
    
    @discardableResult
    func setRxIQBalanceMode(channel: Int, automatic: Bool) -> Int {
        Int(SoapySDRDevice_setIQBalanceMode(
            cDevice,
            SoapyDirection.rx.rawValue,
            numericCast(channel),
            automatic
        ))
    }
    
    @discardableResult
    func setTxIQBalanceMode(channel: Int, automatic: Bool) -> Int {
        Int(SoapySDRDevice_setIQBalanceMode(
            cDevice,
            SoapyDirection.tx.rawValue,
            numericCast(channel),
            automatic
        ))
    }
    
    func rxIQBalanceMode(channel: Int) -> Bool {
        SoapySDRDevice_getIQBalanceMode(cDevice, SoapyDirection.rx.rawValue, numericCast(channel))
    }
    
    func txIQBalanceMode(channel: Int) -> Bool {
        SoapySDRDevice_getIQBalanceMode(cDevice, SoapyDirection.tx.rawValue, numericCast(channel))
    }
    
    func rxHasFrequencyCorrection(channel: Int) -> Bool {
        SoapySDRDevice_hasFrequencyCorrection(cDevice, SoapyDirection.rx.rawValue, numericCast(channel))
    }
    
    func txHasFrequencyCorrection(channel: Int) -> Bool {
        SoapySDRDevice_hasFrequencyCorrection(cDevice, SoapyDirection.tx.rawValue, numericCast(channel))
    }
    
    @discardableResult
    func setRxFrequencyCorrection(channel: Int, ppm: Double) -> Int {
        Int(SoapySDRDevice_setFrequencyCorrection(
            cDevice,
            SoapyDirection.rx.rawValue,
            numericCast(channel),
            ppm
        ))
    }
    
    @discardableResult
    func setTxFrequencyCorrection(channel: Int, ppm: Double) -> Int {
        Int(SoapySDRDevice_setFrequencyCorrection(
            cDevice,
            SoapyDirection.tx.rawValue,
            numericCast(channel),
            ppm
        ))
    }
    
    func rxFrequencyCorrection(channel: Int) -> Double {
        SoapySDRDevice_getFrequencyCorrection(cDevice, SoapyDirection.rx.rawValue, numericCast(channel))
    }
    
    func txFrequencyCorrection(channel: Int) -> Double {
        SoapySDRDevice_getFrequencyCorrection(cDevice, SoapyDirection.tx.rawValue, numericCast(channel))
    }
    
}
