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
        print(device.description)
    }
    
}
