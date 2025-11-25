import XCTest
@testable import SoapySDRWrapper

final class SoapySDRWrapperTests: XCTestCase {
    
    func testEnumerate() {
        let deviceList = SoapyProbe.listDevices()
        for device in deviceList {
            print("testEnumerate: Device -> \(device.description)")
        }
    }
    
    func testSoapyDevice() throws {
        let allDeviceKwargs = SoapyProbe.listDevices()
        guard allDeviceKwargs.count > 0 else { throw XCTSkip("testSoapyDevice: Need at least 1 device to run.") }
        let deviceKwargs = allDeviceKwargs[0]
        print("testSoapyDevice: Device Kwargs -> \(deviceKwargs.description)")
        let device = try SoapyDevice(kwargs: deviceKwargs)
        
        guard let deviceDriver = device.driverName else {
            XCTFail("testSoapyDevice: Failed to get driver name.")
            return
        }
        print("testSoapyDevice: Driver -> \(deviceDriver)")
        
        guard let deviceHardware = device.hardwareName else {
            XCTFail("testSoapyDevice: Failed to get hardware name.")
            return
        }
        print("testSoapyDevice: Hardware -> \(deviceHardware)")
        
        let deviceInfo = device.hardwareKwargs
        print("testSoapyDevice: Hardware Kwargs -> \(deviceInfo.description)")
        
        guard let deviceRXMapping = device.rxFrontendMapping else {
            XCTFail("testSoapyDevice: Failed to get RX frontend mapping.")
            return
        }
        print("testSoapyDevice: RX Mapping -> \(deviceRXMapping)")
        
        guard let deviceTXMapping = device.txFrontendMapping else {
            XCTFail("testSoapyDevice: Failed to get TX frontend mapping.")
            return
        }
        print("testSoapyDevice: TX Mapping -> \(deviceTXMapping)")
        
        print("testSoapyDevice: RX channel count -> \(device.rxNumChannels)")
        print("testSoapyDevice: TX channel count -> \(device.txNumChannels)")
    }
    
}
