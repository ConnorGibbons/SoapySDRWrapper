//
//  Stream.swift
//  SoapySDRWrapper
//
//  Created by Connor Gibbons  on 12/9/25.
//

import Foundation
import complex_h
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
            let channelCount: size_t = channelPtr.count
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
    
    func readStream(stream: OpaquePointer, format: String, channelCount: Int,  numSamples: Int, timeoutMicroseconds: Int) -> ([Data], Int32, Int64, Int32)? {
        let returnedFlags = getMutablePointerForValue(value: Int32(0))
        let bufferTimestamp = getMutablePointerForValue(value: Int64(0))
        let isComplex = format.hasPrefix("C")
        guard let sampleSizeBits = Int(format.filter { $0.isNumber }) else {
            print("SoapySDRDevice: Error reading stream, couldn't get sample size in bits.")
            return nil
        }
        guard sampleSizeBits > 0 && sampleSizeBits % 8 == 0 else {
            print("SoapySDRDevice: Error reading stream, sample size isn't byte aligned: \(sampleSizeBits)")
            return nil
        }
        let sampleSizeBytes = sampleSizeBits / 8 * (isComplex ? 2 : 1)
        let totalBytesPerChannel = sampleSizeBytes * numSamples
        
        
        var buffers: [UnsafeMutableRawPointer?] = []
        buffers.reserveCapacity(channelCount)
        
        for _ in 0..<channelCount {
            let pointer = malloc(totalBytesPerChannel)
            guard let pointer else {
                for p in buffers { if let p { free(p) } }
                print("SoapySDRDevice: Failed to get buffer pointer for stream read.")
                return nil
            }
            buffers.append(pointer)
        }
        
        let readSamples: Int32 = buffers.withUnsafeBufferPointer { buffersPointer in
            let base = buffersPointer.baseAddress
            return SoapySDRDevice_readStream(self.cDevice, stream, base, numSamples, returnedFlags, bufferTimestamp, timeoutMicroseconds)
        }
        
        guard readSamples > 0 else {
            for ptr in buffers {
                free(ptr)
            }
           return nil
        }
        if(readSamples != numSamples) {
            print("SoapySDRDevice: Did not read expected number of samples: \(readSamples), expected: \(numSamples)")
        }
        let bytesRead = numSamples * sampleSizeBytes
        let out: [Data] = buffers.map { pointer in
            Data(bytesNoCopy: pointer!, count: bytesRead, deallocator: .free)
        }
        return (out, returnedFlags.pointee, bufferTimestamp.pointee, readSamples)
    }
}
