//
//  SoapyDevice.swift
//  SoapySDRWrapper
//
//  Created by Connor Gibbons  on 11/25/25.
//
import Foundation
import CSoapySDR

class SoapyDevice {
    let cDevice: OpaquePointer
    
    // --- Device Metadata ---
    var driverName: String? {
        guard let driverNamePtr = SoapySDRDevice_getDriverKey(cDevice) else { return nil }
        return String(cString: driverNamePtr)
    }
    var hardwareName: String? {
        guard let hardwareNamePtr = SoapySDRDevice_getHardwareKey(cDevice) else { return nil }
        return String(cString: hardwareNamePtr)
    }
    var hardwareKwargs: SoapyKwargs {
        return SoapyKwargs(cKwargs: SoapySDRDevice_getHardwareInfo(cDevice))
    }
    
    // --- Device RX/TX Capabilities ---
    var rxFrontendMapping: String? {
        guard let mappingPtr = SoapySDRDevice_getFrontendMapping(cDevice, SoapyDirection.rx.rawValue) else {
            return nil
        }
        // SoapySDR API expects caller to free this
        defer { SoapySDR_free(mappingPtr) }
        return String(cString: mappingPtr)
    }
    var txFrontendMapping: String? {
        guard let mappingPtr = SoapySDRDevice_getFrontendMapping(cDevice, SoapyDirection.tx.rawValue) else {
            return nil
        }
        defer { SoapySDR_free(mappingPtr) }
        return String(cString: mappingPtr)
    }
    var rxNumChannels: Int {
        Int(SoapySDRDevice_getNumChannels(cDevice, SoapyDirection.rx.rawValue))
    }
    var txNumChannels: Int {
        Int(SoapySDRDevice_getNumChannels(cDevice, SoapyDirection.tx.rawValue))
    }
    func rxChannelInfo(channel: Int) -> SoapyKwargs {
        let info = SoapySDRDevice_getChannelInfo(
            cDevice,
            SoapyDirection.rx.rawValue,
            numericCast(channel)
        )
        return SoapyKwargs(cKwargs: info)
    }
    func txChannelInfo(channel: Int) -> SoapyKwargs {
        let info = SoapySDRDevice_getChannelInfo(
            cDevice,
            SoapyDirection.tx.rawValue,
            numericCast(channel)
        )
        return SoapyKwargs(cKwargs: info)
    }
    func rxIsFullDuplex(channel: Int) -> Bool {
        SoapySDRDevice_getFullDuplex(
            cDevice,
            SoapyDirection.rx.rawValue,
            numericCast(channel)
        )
    }
    func txIsFullDuplex(channel: Int) -> Bool {
        SoapySDRDevice_getFullDuplex(
            cDevice,
            SoapyDirection.tx.rawValue,
            numericCast(channel)
        )
    }
    
    init(kwargs: SoapyKwargs) throws {
        let cKwargPointer = kwargs.getcKwargsMutablePointer(); defer { cKwargPointer.deallocate() }
        guard let devicePtr = SoapySDRDevice_make(cKwargPointer) else {
            print("SoapySDRWrapper: Failed to create SoapySDRDevice.")
            throw SoapySDRWrapperErrors.deviceInitFailed
        }
        self.cDevice = devicePtr
        
        if(deviceCache.deviceIsPresent(devicePtr)) {
            print("SoapySDRWrapper warning: Device already present in cache, this SoapyDevice will refer to the same SDR as an existing SoapyDevice.")
        }
        deviceCache.addDevice(devicePtr)
    }
    
    deinit {
        deviceCache.removeDevice(cDevice)
        SoapySDRDevice_unmake(cDevice)
    }
}
