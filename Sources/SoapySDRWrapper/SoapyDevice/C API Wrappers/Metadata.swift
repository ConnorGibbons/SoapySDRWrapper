//
//  Metadata.swift
//  SoapySDRWrapper
//
//  Created by Connor Gibbons  on 12/3/25.
//
import CSoapySDR

extension SoapyDevice {

    // --- Device Metadata ---
    var driverName: String? {
        queue.sync {
            guard let driverNamePtr = SoapySDRDevice_getDriverKey(cDevice) else { return nil }
            defer { SoapySDR_free(driverNamePtr) }
            return String(cString: driverNamePtr)
        }
    }

    var hardwareName: String? {
        queue.sync {
            guard let hardwareNamePtr = SoapySDRDevice_getHardwareKey(cDevice) else { return nil }
            defer { SoapySDR_free(hardwareNamePtr) }
            return String(cString: hardwareNamePtr)
        }
    }

    var hardwareKwargs: SoapyKwargs {
        queue.sync {
            return SoapyKwargs(cKwargs: SoapySDRDevice_getHardwareInfo(cDevice))
        }
    }

}
