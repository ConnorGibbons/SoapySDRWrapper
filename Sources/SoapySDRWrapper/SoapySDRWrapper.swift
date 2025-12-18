import CSoapySDR
import Foundation

/// Cache for open device pointers. Used to determine if a call to SoapySDRDevice\_make is actually returning a pointer to an already opened device.
/// Functions for device discovery & error discovery.
class SoapyDeviceCache: @unchecked Sendable {
    var deviceCache: [OpaquePointer: Int]
    var potentialDevices: [SoapyKwargs]
    let queue = DispatchQueue(label: "SoapyDeviceCache")
    
    init() {
        deviceCache = [:]
        potentialDevices = []
    }
    
    func deviceIsPresent(_ devicePointer: OpaquePointer) -> Bool {
        queue.sync {
            return deviceCache.keys.contains(devicePointer)
        }
    }
    
    func addDevice(_ devicePointer: OpaquePointer) {
        queue.sync {
            let value = deviceCache[devicePointer] ?? 0
            deviceCache.updateValue(value + 1, forKey: devicePointer)
        }
    }
    
    func removeDevice(_ devicePointer: OpaquePointer) {
        queue.sync {
            guard let oldValue = deviceCache[devicePointer] else { return }
            if oldValue == 1 {
                print("SoapyDeviceCache: Removing device \(devicePointer) from cache, no more references")
                deviceCache.removeValue(forKey: devicePointer)
            }
            else {
                deviceCache.updateValue(oldValue - 1, forKey: devicePointer)
            }
        }
    }
    
    func presentPotentialDevices() -> String {
        guard !potentialDevices.isEmpty else { return "No Soapy SDR devices available.\n" }
        var result: String = "--- Potential Soapy SDR Devices ---\n"
        result += "Format: '(index): SoapyKwargs'\n"
        for i in 0..<potentialDevices.count {
            result += " \(i): \(potentialDevices[i].description)\n"
        }
        return result
    }
    
}
let deviceCache = SoapyDeviceCache()

enum SoapyProbe {
    
    public static func listDevices() -> [SoapyKwargs] {
        let lengthPtr = UnsafeMutablePointer<Int>.allocate(capacity: 1)
        guard let devices = SoapySDRDevice_enumerateStrArgs("", lengthPtr) else { return [] }
        var result: [SoapyKwargs] = []
        for i in 0..<lengthPtr.pointee {
            result.append(SoapyKwargs(cKwargs: devices[i]))
        }
        deviceCache.potentialDevices = result
        return result
    }
    
    public static func lastStatus() -> Int {
        return Int(SoapySDRDevice_lastStatus())
    }
    
    public static func lastError() -> String {
        return String(cString: SoapySDRDevice_lastError())
    }
    
}










