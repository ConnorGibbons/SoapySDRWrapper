//
//  Stream.swift
//  SoapySDRWrapper
//
//  Created by Connor Gibbons  on 12/9/25.
//

import Foundation
import CSoapySDR

extension SoapyDevice {
    
    func rxChannelStreamFormats(channel: Int) -> [String] {
        var length: size_t = 0
        guard let list = SoapySDRDevice_getStreamFormats(self.cDevice, SoapyDirection.rx.rawValue, channel, &length) else { return [] }
        var result: [String] = []
        for i in 0..<Int(length) {
            if let ptr = list[i] {
                result.append(String(cString: ptr))
                SoapySDR_free(ptr)
            }
        }
        return result
    }
    
    func rxChannelStreamNativeFormat(channel: Int) -> String? {
        var fullScale: CDouble = 0 // Could be useful in the future, but doing nothing with it for now
        guard let nativeFormat = SoapySDRDevice_getNativeStreamFormat(self.cDevice, SoapyDirection.rx.rawValue, channel, &fullScale) else { return nil }
        return String(cString: nativeFormat)
    }
    
    func rxChannelStreamArgumentsInfo(channel: Int) -> [SoapySDRArgInfo] {
        var length: size_t = 0
        guard let ptr = SoapySDRDevice_getStreamArgsInfo(self.cDevice, SoapyDirection.rx.rawValue, channel, &length) else { return [] }
        let buffer = UnsafeBufferPointer(start: ptr, count: Int(length))
        let info = Array(buffer)
        return info
    }
    
    func rxSetupStream(channels: [Int], format: String, args: SoapySDRKwargs = SoapySDRKwargs()) -> OpaquePointer {
        channels.withUnsafeBufferPointer { channelPtr in
            var kwargs = args
            var channelCount: size_t = channelPtr.count
            return SoapySDRDevice_setupStream(self.cDevice, SoapyDirection.rx.rawValue, format, channelPtr.baseAddress, channelCount, &kwargs)
        }
    }
    
    func getStreamMTU(stream: OpaquePointer) -> Int {
        return SoapySDRDevice_getStreamMTU(self.cDevice, stream)
    }
    
    func closeStream(stream: OpaquePointer) -> Bool {
        let result = SoapySDRDevice_closeStream(self.cDevice, stream)
        if result != 0 {
            print("SoapySDRDevice: Error closing stream: \(result)")
            return false
        }
        return true
    }
    
    func activateStream(stream: OpaquePointer, flags: Int, timeNanoseconds: Int, numElements: Int? = nil) -> Bool {
        let result = SoapySDRDevice_activateStream(self.cDevice, stream, Int32(flags), Int64(timeNanoseconds), numElements ?? 0)
        if result != 0 {
            print("SoapySDRDevice: Error activating stream: \(result)")
            return false
        }
        return true
    }
    
    func deactivateStream(stream: OpaquePointer, flags: Int, timeNanoseconds: Int) -> Bool {
        let result = SoapySDRDevice_deactivateStream(self.cDevice, stream, Int32(flags), Int64(timeNanoseconds))
        if result != 0 {
            print("SoapySDRDevice: Error deactivating stream: \(result)")
            return false
        }
        return true
    }
    
    
}



class SoapyStream {
    let device: SoapyDevice
    let cStream: OpaquePointer
    let format: String
    
    init?(forDevice: SoapyDevice, direction: SoapyDirection, channel: Int) {
        self.device = forDevice
        guard let nativeFormat = direction == .rx ? forDevice.rxChannelStreamNativeFormat(channel: channel) : nil else { return nil }
        self.cStream = forDevice.rxCh
    }
}
