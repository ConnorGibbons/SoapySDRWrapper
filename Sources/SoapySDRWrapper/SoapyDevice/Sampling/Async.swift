//
//  Async.swift
//  SoapySDRWrapper
//
//  Created by Connor Gibbons  on 12/18/25.
//
import Foundation
import CSoapySDR

extension SoapyDevice {
    
    private func handlerExistsWithID(_ id: Int) -> Bool {
        return self.asyncHandlerDictionary[id] != nil
    }
    
    private func addHandlerToDict(_ handler: AsyncHandler) -> Int {
        let id = self.getNextAsyncHandlerId()
        self.asyncHandlerDictionary[id] = handler
        return id
    }
    
    /// Asynchronous reading function allowing for a user defined callback.
    /// T is implied by the type used in callback; the type used must conform to SampleData.
    /// Will return an id (Int) that must be stored so it can be used to stop the stream later.
    public func asyncReadSamples<T: SampleData>(channels: [Int], callback: @escaping ([[T]]) -> Void) throws -> Int {
        do {
            let handler = try SoapyAsyncHandler<T>(device: self, channels: channels)
            let id = self.addHandlerToDict(handler)
            try handler.startAsyncRead(callback: callback)
            return id
        }
        catch {
            print("SoapySDRWrapper: Error in asyncReadSamples: \(error)")
            print(SoapyProbe.lastError())
            throw error
        }
    }
    
    public func asyncStopReadingSamples(id: Int) {
        guard handlerExistsWithID(id) else { return }
        let handler = self.asyncHandlerDictionary[id]!
        handler.stopRead()
        self.asyncHandlerDictionary.removeValue(forKey: id)
    }
    
}

public protocol SampleData {
    static func arrayFrom(_ floats: [Float]) -> [Self]?
    static func arrayFrom(_ doubles: [Double]) -> [Self]?
    static func arrayFrom<T: FixedWidthInteger & UnsignedInteger>(_ integers: [T]) -> [Self]?
    static func arrayFrom<T: FixedWidthInteger & SignedInteger>(_ integers: [T]) -> [Self]?
}

func decode<T: SampleData>(_ data: Data, format: String) -> [T]? {
    guard let bitLength = Int(format.filter { $0.isNumber }) else { return nil }
    guard bitLength % 8 == 0 else {
        print("Can't get samples from Data, format \(format) is not byte aligned.")
        return nil
    }
    
    if format.contains("F") {
        if(bitLength == 32) {
            guard let floatData: [Float] = reinterpretDataAsType(input: data, type: Float.self) else { return nil }
            guard floatData.count > 0 else { return nil }
            return T.arrayFrom(floatData)
        }
        else if(bitLength == 64) {
            guard let doubleData: [Double] = reinterpretDataAsType(input: data, type: Double.self) else { return nil }
            guard doubleData.count > 0 else { return nil }
            return T.arrayFrom(doubleData)
        }
        else {
            print("Unsupported bit length for floating point: \(bitLength)")
            return nil
        }
    }
    else if format.contains("S") {
        if(bitLength == 64) {
            guard let intData: [Int64] = reinterpretDataAsType(input: data, type: Int64.self) else { return nil }
            guard intData.count > 0 else { return nil }
            return T.arrayFrom(intData)
        }
        else if (bitLength == 32) {
            guard let intData: [Int32] = reinterpretDataAsType(input: data, type: Int32.self) else { return nil }
            guard intData.count > 0 else { return nil }
            return T.arrayFrom(intData)
        }
        else if (bitLength == 16) {
            guard let intData: [Int16] = reinterpretDataAsType(input: data, type: Int16.self) else { return nil }
            guard intData.count > 0 else { return nil }
            return T.arrayFrom(intData)
        }
        else if (bitLength == 8) {
            guard let intData: [Int8] = reinterpretDataAsType(input: data, type: Int8.self) else { return nil }
            guard intData.count > 0 else { return nil }
            return T.arrayFrom(intData)
        }
        else {
            print("Unsupported bit length for signed integer: \(bitLength)")
            return nil
        }
    }
    else if format.contains("U") {
        if (bitLength == 64) {
            guard let intData: [UInt64] = reinterpretDataAsType(input: data, type: UInt64.self) else { return nil }
            guard intData.count > 0 else { return nil }
            return T.arrayFrom(intData)
        }
        else if (bitLength == 32) {
            guard let intData: [UInt32] = reinterpretDataAsType(input: data, type: UInt32.self) else { return nil }
            guard intData.count > 0 else { return nil }
            return T.arrayFrom(intData)
        }
        else if (bitLength == 16) {
            guard let intData: [UInt16] = reinterpretDataAsType(input: data, type: UInt16.self) else { return nil }
            guard intData.count > 0 else { return nil }
            return T.arrayFrom(intData)
        }
        else if (bitLength == 8) {
            guard let intData: [UInt8] = reinterpretDataAsType(input: data, type: UInt8.self) else { return nil }
            guard intData.count > 0 else { return nil }
            return T.arrayFrom(intData)
        }
        else {
            print("Unsupported bit length for unsigned integer: \(bitLength)")
            return nil
        }
    }
    else {
        print("Can't get samples from data, format \(format) is not supported.")
        return nil
    }
}

/// To be used as the output type for real-valued stream reads.
/// Uses Float internally, value range: [-1,1].
public struct Sample: Equatable, SampleData {
    public let value: Float
    
    /// Initializes [Sample] from [Float]. Note that this assumes that the values are already in the range [-1,1].
    public static func arrayFrom(_ floats: [Float]) -> [Sample]? {
        return floats.map { Sample(value: $0) }
    }
    
    /// Initializes [Sample] from [Double], note that this will lose precision by converting from Double to Float internally. Note that this assumes values are already in the range [-1,1].
    public static func arrayFrom(_ doubles: [Double]) -> [Sample]? {
        return doubles.map { Sample(value: Float($0)) }
    }
    
    public static func arrayFrom<T>(_ integers: [T]) -> [Sample]? where T : FixedWidthInteger, T : UnsignedInteger {
        let scale = Float(T.max)
        return integers.map {
            let asFloat = Float($0)
            return Sample(value: (asFloat / scale) * 2 - 1)
        }
    }
    
    public static func arrayFrom<T>(_ integers: [T]) -> [Sample]? where T : FixedWidthInteger, T : SignedInteger {
        let scale = Float(T.max)
        return integers.map {
            let asFloat = Float($0)
            return Sample(value: Swift.max(-1.0, asFloat / scale))
        }
    }
    
}

private func reinterpretDataAsType<T>(input: Data, type: T.Type) -> [T]? {
    let reinterpretedData: [T]? = input.withUnsafeBytes { rawBufferPointer in
        guard rawBufferPointer.count % MemoryLayout<T>.size == 0 else {
            print("The provided data is not aligned to \(type)")
            return nil
        }
        let tPointer = rawBufferPointer.bindMemory(to: type.self)
        return Array(tPointer)
    }
    return reinterpretedData
}

// To optionally be used as the output type for real-valued stream reads.
public struct PreciseSample: Equatable, SampleData {
    public let value: Double
    
    /// Initializes [PreciseSample] from [Float]. Note that this assumes that the values are already in the range [-1,1].
    public static func arrayFrom(_ floats: [Float]) -> [PreciseSample]? {
        return floats.map { PreciseSample(value: Double($0)) }
    }
    
    /// Initializes [PreciseSample] from [Double].  Note that this assumes values are already in the range [-1,1].
    public static func arrayFrom(_ doubles: [Double]) -> [PreciseSample]? {
        return doubles.map { PreciseSample(value: $0) }
    }
    
    public static func arrayFrom<T>(_ integers: [T]) -> [PreciseSample]? where T : FixedWidthInteger, T : UnsignedInteger {
        let scale = Double(T.max)
        return integers.map {
            let asFloat = Double($0)
            return PreciseSample(value: (asFloat / scale) * 2 - 1)
        }
    }
    
    public static func arrayFrom<T>(_ integers: [T]) -> [PreciseSample]? where T : FixedWidthInteger, T : SignedInteger {
        let scale = Double(T.max)
        return integers.map {
            let asFloat = Double($0)
            return PreciseSample(value: Swift.max(-1.0, asFloat / scale))
        }
    }
    
    
}

// To be used as the output type for complex-valued stream reads.
public struct ComplexSample: Equatable, SampleData {
    public let real: Float
    public let imag: Float
    
    /// Initializes [ComplexSample] from [Float].
    /// Makes a few assumptions:
    /// 1. That the sample values are already in the range [-1,1]
    /// 2. That the sample values consist of interleaved IQ samples.
    /// The resulting ComplexSample array will have (floats.count / 2) elements.
    /// If floats does not have an even number of elements, nil will be returned.
    public static func arrayFrom(_ floats: [Float]) -> [ComplexSample]? {
        guard floats.count % 2 == 0 else { return nil }
        return stride(from: 0, to: floats.count, by: 2).map {
            ComplexSample(real: floats[$0], imag: floats[$0 + 1])
        }
    }
    
    /// Initializes [ComplexSample] from [Float].
    /// Makes a few assumptions:
    /// 1. That the sample values are already in the range [-1,1]
    /// 2. That the sample values consist of interleaved IQ samples.
    /// The resulting ComplexSample array will have (floats.count / 2) elements.
    /// If floats does not have an even number of elements, nil will be returned.
    public static func arrayFrom(_ doubles: [Double]) -> [ComplexSample]? {
        guard doubles.count % 2 == 0 else { return nil }
        return stride(from: 0, to: doubles.count, by: 2).map {
            ComplexSample(real: Float(doubles[$0]), imag: Float(doubles[$0 + 1]))
        }
    }
    
    public static func arrayFrom<T>(_ integers: [T]) -> [ComplexSample]? where T : FixedWidthInteger, T : UnsignedInteger {
        guard integers.count % 2 == 0 else { return nil }
        let scale = Float(T.max)
        return stride(from: 0, to: integers.count, by: 2).map {
            let realScaled = (Float(integers[$0]) / scale) * 2 - 1
            let imagScaled = (Float(integers[$0 + 1]) / scale) * 2 - 1
            return ComplexSample(real: realScaled, imag: imagScaled)
        }
    }
    
    public static func arrayFrom<T>(_ integers: [T]) -> [ComplexSample]? where T : FixedWidthInteger, T : SignedInteger {
        guard integers.count % 2 == 0 else { return nil }
        let scale = Float(T.max)
        return stride(from: 0, to: integers.count, by: 2).map {
            let realScaled = Swift.max(-1.0, Float(integers[$0]) / scale)
            let imagScaled = Swift.max(-1.0, Float(integers[$0 + 1]) / scale)
            return ComplexSample(real: realScaled, imag: imagScaled)
        }
    }
    
}

// To optionally be used as the output type for complex-valued stream reads.
public struct PreciseComplexSample: Equatable, SampleData {
    public let real: Double
    public let imag: Double
    
    /// Initializes [PreciseComplexSample] from [Float].
    /// Makes a few assumptions:
    /// 1. That the sample values are already in the range [-1,1]
    /// 2. That the sample values consist of interleaved IQ samples.
    /// The resulting ComplexSample array will have (floats.count / 2) elements.
    /// If floats does not have an even number of elements, nil will be returned.
    public static func arrayFrom(_ floats: [Float]) -> [PreciseComplexSample]? {
        guard floats.count % 2 == 0 else { return nil }
        return stride(from: 0, to: floats.count, by: 2).map {
            PreciseComplexSample(real: Double(floats[$0]), imag: Double(floats[$0 + 1]))
        }
    }
    
    /// Initializes [PreciseComplexSample] from [Float].
    /// Makes a few assumptions:
    /// 1. That the sample values are already in the range [-1,1]
    /// 2. That the sample values consist of interleaved IQ samples.
    /// The resulting ComplexSample array will have (floats.count / 2) elements.
    /// If floats does not have an even number of elements, nil will be returned.
    public static func arrayFrom(_ doubles: [Double]) -> [PreciseComplexSample]? {
        guard doubles.count % 2 == 0 else { return nil }
        return stride(from: 0, to: doubles.count, by: 2).map {
            PreciseComplexSample(real: doubles[$0], imag: doubles[$0 + 1])
        }
    }
    
    public static func arrayFrom<T>(_ integers: [T]) -> [PreciseComplexSample]? where T : FixedWidthInteger, T : UnsignedInteger {
        guard integers.count % 2 == 0 else { return nil }
        let scale = Double(T.max)
        return stride(from: 0, to: integers.count, by: 2).map {
            let realScaled = (Double(integers[$0]) / scale) * 2 - 1
            let imagScaled = (Double(integers[$0 + 1]) / scale) * 2 - 1
            return PreciseComplexSample(real: realScaled, imag: imagScaled)
        }
    }
    
    public static func arrayFrom<T>(_ integers: [T]) -> [PreciseComplexSample]? where T : FixedWidthInteger, T : SignedInteger {
        guard integers.count % 2 == 0 else { return nil }
        let scale = Double(T.max)
        return stride(from: 0, to: integers.count, by: 2).map {
            let realScaled = Swift.max(-1.0, Double(integers[$0]) / scale)
            let imagScaled = Swift.max(-1.0, Double(integers[$0 + 1]) / scale)
            return PreciseComplexSample(real: realScaled, imag: imagScaled)
        }
    }
}

protocol AsyncHandler {
    func stopRead()
    func getHandlerIsActive() -> Bool
}

public class SoapyAsyncHandler<T: SampleData>: AsyncHandler {
    private let isActiveQueue: DispatchQueue = .init(label: "SoapyAsyncIsActiveQueue")
    private let readingQueue: DispatchQueue = .init(label: "SoapyAsyncReadingQueue")
    private let device: SoapyDevice
    private var stream: OpaquePointer
    private var streamFormat: String
    private var channelCount: Int
    private let streamMTU: Int // Not guaranteed to return this # of samples, but it's optimal to use it in readStream (supposedly)
    private let buffers: [UnsafeMutableRawPointer?]
    public var handlerIsActive: Bool
    
    public init(device: SoapyDevice, channels: [Int]) throws {
        self.device = device
        
        guard !channels.isEmpty else { throw SoapyAsyncError.invalidChannelSelection }
        guard let nativeFormat = device.rxChannelStreamNativeFormat(channel: channels.first!) else { throw SoapyAsyncError.noNativeFormat }
        self.streamFormat = nativeFormat
        self.channelCount = channels.count
        SoapyAsyncHandler<T>.printTypeWarningIfApplicable(streamIsComplex: nativeFormat.hasPrefix("C"), type: T.self)
        
        guard let newStream = device.rxSetupStream(channels: channels, format: nativeFormat) else {
            throw SoapyAsyncError.streamSetupFailed
        }
        self.stream = newStream
        self.streamMTU = device.getStreamMTU(stream: stream)
        
        guard let bytesPerChannel = getTotalBytesPerChannel(format: nativeFormat, numSamples: streamMTU) else {
            print("SoapyAsyncHandler: Failed to get total bytes per channel.")
            throw SoapyAsyncError.streamActivationFailed
        }
        var buffers: [UnsafeMutableRawPointer?] = []
        for _ in 0..<channelCount {
            let bufferPointer = getSampleBuffer(totalBytesPerChannel: bytesPerChannel)
            buffers.append(bufferPointer)
        }
        self.buffers = buffers
        
        self.handlerIsActive = false
    }
    
    public func startAsyncRead(callback: @escaping ([[T]]) -> Void) throws {
        guard !self.getHandlerIsActive() else { throw SoapyAsyncError.handlerAlreadyActive }
        self.setHandlerIsActive(true)
        try device.activateStream(stream: self.stream, flags: 0, timeNanoseconds: 0)
        
        func readDataFromStream(callback: @escaping ([[T]]) -> Void) throws {
            let (sampleData, _, _, _) = try self.device.readStream(stream: self.stream, format: self.streamFormat, channelCount: self.channelCount, numSamples: self.streamMTU, timeoutMicroseconds: 1_000_000, buffers: self.buffers)
            let asTArray: [[T]?] = sampleData.map { decode($0, format: self.streamFormat) }
            if asTArray.contains(where: { $0 == nil }) { try self.stopAsyncRead(); }
            let asTArrayNoOptionals: [[T]] = asTArray.compactMap { $0 }
            callback(asTArrayNoOptionals)
        }
        
        readingQueue.async {
            while self.getHandlerIsActive() {
                do {
                    try readDataFromStream(callback: callback)
                } catch {
                    do {
                        print("SoapyAsyncHandler: Stream read failed, \(error.localizedDescription), retrying...")
                        try readDataFromStream(callback: callback)
                    }
                    catch {
                        print("SoapyAsyncHandler: Stream read failed, \(error.localizedDescription), stopping...")
                        do {
                            try self.stopAsyncRead()
                        }
                        catch {
                            print("SoapyAsyncHandler: Call to stopAsyncRead threw: \(error.localizedDescription)")
                        }
                        break
                    }
                }
            }
        }
    }
    
   public func stopAsyncRead() throws {
        try self.device.deactivateStream(stream: self.stream, flags: 0, timeNanoseconds: 0)
        self.setHandlerIsActive(false)
    }
    
    public func stopRead() {
        do {
            try self.stopAsyncRead()
        }
        catch {
            print("SoapyAsyncHandler: Failed to stop async read.")
        }
    }

    private static func printTypeWarningIfApplicable<X: SampleData>(streamIsComplex: Bool, type: X.Type) {
        switch type {
        case is Sample.Type:
            if streamIsComplex {
                print("SoapyAsyncHandler: Warning! Using Sample (non-complex) as output type for a complex-valued stream. Stream will need to be handled as interleaved IQ data.")
            }
        case is PreciseSample.Type:
            if streamIsComplex {
                print("SoapyAsyncHandler: Warning! Using PreciseSample (non-complex) as output type for a complex-valued stream. Stream will need to be handled as interleaved IQ data.")
            }
        case is ComplexSample.Type:
            if !streamIsComplex {
                print("SoapyAsyncHandler: Warning! Using ComplexSample as output type for a non-complex valued stream. Each sample will consist of two consecutively sampled real values.")
            }
        case is PreciseComplexSample.Type:
            if !streamIsComplex {
                print("SoapyAsyncHandler: Warning! Using PreciseComplexSample as output type for a non-complex valued stream. Each sample will consist of two consecutively sampled real values.")
            }
        default:
            break
        }
    }

    public func getHandlerIsActive() -> Bool {
        self.isActiveQueue.sync {
            return self.handlerIsActive
        }
    }
    
    func setHandlerIsActive(_ value: Bool) {
        self.isActiveQueue.sync {
            self.handlerIsActive = value
        }
    }
    
}

enum SoapyAsyncError: Error {
    case invalidChannelSelection
    case noNativeFormat
    case handlerAlreadyActive
    case streamActivationFailed
    case streamSetupFailed
}

