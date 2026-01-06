//
//  Bandwidth.swift
//  SoapySDRWrapper
//
//  Created by Connor Gibbons  on 12/3/25.
//

import CSoapySDR

extension SoapyDevice {

    // --- Bandwidth API ---
    @discardableResult
    func setBandwidth(direction: SoapyDirection, channel: Int, bw: Double) -> Int {
        queue.sync {
            Int(SoapySDRDevice_setBandwidth(
                cDevice,
                direction.rawValue,
                numericCast(channel),
                bw
            ))
        }
    }

    func bandwidth(direction: SoapyDirection, channel: Int) -> Double {
        queue.sync {
            SoapySDRDevice_getBandwidth(cDevice, direction.rawValue, numericCast(channel))
        }
    }

    func bandwidths(direction: SoapyDirection, channel: Int) -> [Double] {
        queue.sync {
            var length: size_t = 0
            guard let ptr = SoapySDRDevice_listBandwidths(
                cDevice,
                direction.rawValue,
                numericCast(channel),
                &length
            ) else { return [] }
            let buffer = UnsafeBufferPointer(start: ptr, count: Int(length))
            let bws = Array(buffer)
            SoapySDR_free(ptr)
            return bws
        }
    }

    func bandwidthRanges(direction: SoapyDirection, channel: Int) -> [SoapySDRRange] {
        queue.sync {
            var length: size_t = 0
            guard let ptr = SoapySDRDevice_getBandwidthRange(
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

}
