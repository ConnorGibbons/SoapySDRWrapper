//
//  TXRXInfo.swift
//  SoapySDRWrapper
//
//  Created by Connor Gibbons  on 12/3/25.
//

import CSoapySDR

extension SoapyDevice {

    // --- Device RX/TX Capabilities ---
    var rxFrontendMapping: String? {
        queue.sync {
            guard let mappingPtr = SoapySDRDevice_getFrontendMapping(cDevice, SoapyDirection.rx.rawValue) else {
                return nil
            }
            defer { SoapySDR_free(mappingPtr) }
            return String(cString: mappingPtr)
        }
    }

    var txFrontendMapping: String? {
        queue.sync {
            guard let mappingPtr = SoapySDRDevice_getFrontendMapping(cDevice, SoapyDirection.tx.rawValue) else {
                return nil
            }
            defer { SoapySDR_free(mappingPtr) }
            return String(cString: mappingPtr)
        }
    }

//    @discardableResult
//    func setRxFrontendMapping(_ mapping: String) -> Int {
//        Int(SoapySDRDevice_setFrontendMapping(cDevice, SoapyDirection.rx.rawValue, mapping))
//    }
//
//    @discardableResult
//    func setTxFrontendMapping(_ mapping: String) -> Int {
//        Int(SoapySDRDevice_setFrontendMapping(cDevice, SoapyDirection.tx.rawValue, mapping))
//    }

    var rxNumChannels: Int {
        queue.sync {
            Int(SoapySDRDevice_getNumChannels(cDevice, SoapyDirection.rx.rawValue))
        }
    }

    var txNumChannels: Int {
        queue.sync {
            Int(SoapySDRDevice_getNumChannels(cDevice, SoapyDirection.tx.rawValue))
        }
    }

    func rxChannelInfo(channel: Int) -> SoapyKwargs {
        queue.sync {
            let info = SoapySDRDevice_getChannelInfo(
                cDevice,
                SoapyDirection.rx.rawValue,
                numericCast(channel)
            )
            return SoapyKwargs(cKwargs: info)
        }
    }

    func txChannelInfo(channel: Int) -> SoapyKwargs {
        queue.sync {
            let info = SoapySDRDevice_getChannelInfo(
                cDevice,
                SoapyDirection.tx.rawValue,
                numericCast(channel)
            )
            return SoapyKwargs(cKwargs: info)
        }
    }

    func rxIsFullDuplex(channel: Int) -> Bool {
        queue.sync {
            SoapySDRDevice_getFullDuplex(
                cDevice,
                SoapyDirection.rx.rawValue,
                numericCast(channel)
            )
        }
    }

    func txIsFullDuplex(channel: Int) -> Bool {
        queue.sync {
            SoapySDRDevice_getFullDuplex(
                cDevice,
                SoapyDirection.tx.rawValue,
                numericCast(channel)
            )
        }
    }

}
