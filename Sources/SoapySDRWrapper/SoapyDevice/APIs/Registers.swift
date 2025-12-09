//
//  Registers.swift
//  SoapySDRWrapper
//
//  Created by Connor Gibbons  on 12/3/25.
//

import CSoapySDR

extension SoapyDevice {
    
    // --- Register API ---
    func registerInterfaces() -> [String] {
        var length: size_t = 0
        guard let list = SoapySDRDevice_listRegisterInterfaces(cDevice, &length) else { return [] }
        var result: [String] = []
        for i in 0..<Int(length) {
            if let ptr = list[i] {
                result.append(String(cString: ptr))
                SoapySDR_free(ptr)
            }
        }
        return result
    }
    
    func writeRegister(interface name: String, addr: UInt32, value: UInt32) -> Int {
        Int(SoapySDRDevice_writeRegister(cDevice, name, addr, value))
    }
    
    func readRegister(interface name: String, addr: UInt32) -> UInt32 {
        SoapySDRDevice_readRegister(cDevice, name, addr)
    }
    
    func writeRegisters(interface name: String, addr: UInt32, values: [UInt32]) -> Int {
        var valuesCopy = values
        return Int(valuesCopy.withUnsafeMutableBufferPointer {
            SoapySDRDevice_writeRegisters(
                cDevice,
                name,
                addr,
                $0.baseAddress,
                numericCast($0.count)
            )
        })
    }
    
    func readRegisters(interface name: String, addr: UInt32, count: Int) -> [UInt32] {
        var length: size_t = numericCast(count)
        guard let ptr = SoapySDRDevice_readRegisters(
            cDevice,
            name,
            addr,
            &length
        ) else { return [] }
        let buffer = UnsafeBufferPointer(start: ptr, count: Int(length))
        let result = Array(buffer)
        SoapySDR_free(ptr)
        return result
    }
    
}
