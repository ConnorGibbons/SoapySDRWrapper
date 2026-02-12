//
//  Stream.swift
//  SoapySDRWrapper
//
//  Created by Connor Gibbons  on 12/9/25.
//

import Foundation
import CSoapySDR

extension SoapyDevice {
    
    public func rxChannelStreamFormats(channel: Int) -> [String] {
        queue.sync {
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
    }
    
    public func rxChannelStreamNativeFormat(channel: Int) -> String? {
        queue.sync {
            var fullScale: CDouble = 0 // Could be useful in the future, but doing nothing with it for now
            guard let nativeFormat = SoapySDRDevice_getNativeStreamFormat(self.cDevice, SoapyDirection.rx.rawValue, channel, &fullScale) else { return nil }
            return String(cString: nativeFormat)
        }
    }
    
    public func rxChannelStreamArgumentsInfo(channel: Int) -> [SoapySDRArgInfo] {
        queue.sync {
            var length: size_t = 0
            guard let ptr = SoapySDRDevice_getStreamArgsInfo(self.cDevice, SoapyDirection.rx.rawValue, channel, &length) else { return [] }
            let buffer = UnsafeBufferPointer(start: ptr, count: Int(length))
            let info = Array(buffer)
            return info
        }
    }
    
    public func rxSetupStream(channels: [Int], format: String, args: SoapySDRKwargs = SoapySDRKwargs()) -> OpaquePointer? {
        queue.sync {
            channels.withUnsafeBufferPointer { channelPtr in
                var kwargs = args
                let channelCount: size_t = channelPtr.count
                return SoapySDRDevice_setupStream(self.cDevice, SoapyDirection.rx.rawValue, format, channelPtr.baseAddress, channelCount, &kwargs)
            }
        }
    }
    
    public func getStreamMTU(stream: OpaquePointer) -> Int {
        queue.sync {
            return SoapySDRDevice_getStreamMTU(self.cDevice, stream)
        }
    }
    
    public func closeStream(stream: OpaquePointer) throws {
        try queue.sync {
            try SoapySDRMaybeThrowError(code: SoapySDRDevice_closeStream(self.cDevice, stream))
        }
    }
    
    public func activateStream(stream: OpaquePointer, flags: Int, timeNanoseconds: Int, numElements: Int? = nil) throws {
        try queue.sync {
            try SoapySDRMaybeThrowError(code: SoapySDRDevice_activateStream(self.cDevice, stream, Int32(flags), Int64(timeNanoseconds), numElements ?? 0))
        }
    }
    
    public func deactivateStream(stream: OpaquePointer, flags: Int, timeNanoseconds: Int) throws {
        try queue.sync {
            try SoapySDRMaybeThrowError(code: SoapySDRDevice_deactivateStream(self.cDevice, stream, Int32(flags), Int64(timeNanoseconds)))
        }
    }
    
    /// If passing in reusable buffers, ensure that buffers is of size = channelCount, and each buffer contained has at least enough space for numSamples of the provided format.
    public func readStream(stream: OpaquePointer, format: String, channelCount: Int,  numSamples: Int, timeoutMicroseconds: Int, buffers: [UnsafeMutableRawPointer?]? = nil) throws -> ([Data], Int32, Int64, Int32) {
        let returnedFlags = getMutablePointerForValue(value: Int32(0)); defer { returnedFlags.deallocate() }
        let bufferTimestamp = getMutablePointerForValue(value: Int64(0)); defer { bufferTimestamp.deallocate() }
        
        guard let totalBytesPerChannel = getTotalBytesPerChannel(format: format, numSamples: numSamples) else {
            print("SoapySDRDevice: Error reading stream, couldn't get total # of bytes per channel.")
            throw SoapyError.streamError
        }
        let sampleSizeBytes = totalBytesPerChannel / numSamples
        
        var localBuffers: [UnsafeMutableRawPointer?] = []
        if buffers == nil {
            localBuffers.reserveCapacity(channelCount)
            for _ in 0..<channelCount {
                guard let ptr = getSampleBuffer(totalBytesPerChannel: totalBytesPerChannel) else {
                    for ptr in localBuffers {
                        free(ptr)
                    }
                    throw SoapyError.memory
                }
                localBuffers.append(ptr)
            }
        }
        
        let readSamples: Int32 = (buffers ?? localBuffers).withUnsafeBufferPointer { buffersPointer in
            let base = buffersPointer.baseAddress
            return queue.sync {
                return SoapySDRDevice_readStream(self.cDevice, stream, base, numSamples, returnedFlags, bufferTimestamp, timeoutMicroseconds)
            }
        }
        guard readSamples > 0 else {
            try SoapySDRMaybeThrowError(code: readSamples)
            throw SoapyError.streamError
        }
        
//        if(readSamples != numSamples) {
//            print("SoapySDRDevice: Did not read expected number of samples: \(readSamples), expected: \(numSamples)")
//        }
        let bytesRead = Int(readSamples) * sampleSizeBytes
        let out: [Data] = (buffers ?? localBuffers).map { pointer in
            Data(bytesNoCopy: pointer!, count: bytesRead, deallocator: buffers == nil ? .free : .none)
        }
        return (out, returnedFlags.pointee, bufferTimestamp.pointee, readSamples)
    }
}


public func getSampleBuffer(totalBytesPerChannel: Int) -> UnsafeMutableRawPointer? {
    let pointer = malloc(totalBytesPerChannel)
    guard let pointer else { // I don't think this block should really ever get hit. But it's here & frees the memory just in case.
        free(pointer)
        print("SoapySDRDevice: Failed to get buffer pointer for stream read.")
        return nil
    }
    return pointer
}

public func getTotalBytesPerChannel(format: String, numSamples: Int) -> Int? {
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
    return totalBytesPerChannel
}
