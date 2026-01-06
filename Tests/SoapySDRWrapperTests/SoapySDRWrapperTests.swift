import XCTest
@testable import SoapySDRWrapper

final class SoapySDRWrapperTests: XCTestCase {
    
    func testEnumerate() {
        _ = SoapyProbe.listDevices()
        print(deviceCache.presentPotentialDevices())
    }
    
    func testSoapyDevice() throws {
        let allDeviceKwargs = SoapyProbe.listDevices()
        guard allDeviceKwargs.count > 0 else { throw XCTSkip("testSoapyDevice: Need at least 1 device to run.") }
        let deviceKwargs = allDeviceKwargs[0]
        print("testSoapyDevice: Device Kwargs -> \(deviceKwargs.description)")
        let device = try SoapyDevice(kwargs: deviceKwargs)
        print(device.description)
    }
    
    func testSoapyStreamRead() throws {
        // Parameters
        let numSamplesToRead = 131072
        
        let allDeviceKwargs = SoapyProbe.listDevices()
        guard allDeviceKwargs.count > 0 else { throw XCTSkip("testSoapyStreamRead: Need at least 1 device to run.") }
        let deviceKwargs = allDeviceKwargs[0]
        let device = try SoapyDevice(kwargs: deviceKwargs)
        guard device.rxNumChannels > 0 else { throw XCTSkip("testSoapyStreamRead: Need at least 1 RX channel to run.") }
        
        let preferredFormat = device.rxChannelStreamNativeFormat(channel: 0) ?? "CF32"
        let stream = device.rxSetupStream(channels: [0], format: preferredFormat)
        XCTAssertTrue(device.activateStream(stream: stream, flags: 0, timeNanoseconds: 0))
        device.setFrequency(direction: .rx, channel: 0, frequency: 100_100_000)
        device.setGainMode(direction: .rx, channel: 0, automatic: true)
        print(device.description)
        let (samples, flags, timestamp, readCount) = device.readStream(stream: stream, format: preferredFormat, channelCount: 1, numSamples: numSamplesToRead, timeoutMicroseconds: Int(1e6)) ?? ([],0,0,0)
        let (samples1, flags1, timestamp1, readCount1) = device.readStream(stream: stream, format: preferredFormat, channelCount: 1, numSamples: numSamplesToRead, timeoutMicroseconds: Int(1e6)) ?? ([],0,0,0)
        _ = device.closeStream(stream: stream)
        XCTAssert(readCount == numSamplesToRead && readCount1 == numSamplesToRead)
        print("\(readCount1 + readCount) samples in \(timestamp1 - timestamp) nanoseconds, rate: \(Double(readCount1 + readCount) * (1e9 / Double(timestamp1 - timestamp))) samples/second (timestamp-based)")
    }
    
    func testSoapyAsyncHandler() throws {
        // Parameters
        let readSeconds = 20.0
        let sampleRate: Double = 2_400_000
        
        let semQueue = DispatchQueue.init(label: "testAsyncQueue")
        
        let device = try getFirstDevice()
        device.setSampleRate(direction: .rx, channel: 0, rate: sampleRate)
        let sem = DispatchSemaphore(value: 0)
        var count: Int = 0
        let t0 = DispatchTime.now()
        let id = try device.asyncReadSamples(channels: [0], callback: {
            let x: [ComplexSample] = $0[0]
            count += x.count
        })
        semQueue.asyncAfter(deadline: .now() + readSeconds, execute: {
            sem.signal()
        })
        sem.wait()
        device.asyncStopReadingSamples(id: id)
        let t1 = DispatchTime.now()
        let duration = Double(t1.uptimeNanoseconds - t0.uptimeNanoseconds) / 1_000_000
        print("Read \(count) samples in \(duration) ms")
        print("Rate: \(Double(count) / (duration/1000)) samples/s")
    }
    
    private func getFirstDevice() throws -> SoapyDevice {
        let allDeviceKwargs = SoapyProbe.listDevices()
        guard allDeviceKwargs.count > 0 else { throw XCTSkip("testSoapyStreamRead: Need at least 1 device to run.") }
        let deviceKwargs = allDeviceKwargs[0]
        let device = try SoapyDevice(kwargs: deviceKwargs)
        guard device.rxNumChannels > 0 else { throw XCTSkip("testSoapyStreamRead: Need at least 1 RX channel to run.") }
        return device
    }
    
}
