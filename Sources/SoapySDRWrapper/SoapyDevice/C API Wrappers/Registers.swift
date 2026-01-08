//
//  Registers.swift
//  SoapySDRWrapper
//
//  Created by Connor Gibbons  on 12/3/25.
//

import CSoapySDR

extension SoapyDevice {

    // --- Register API ---
    public func registerInterfaces() -> [String] {
        queue.sync {
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
    }

    public func writeRegister(interface name: String, addr: UInt32, value: UInt32) throws {
        try queue.sync {
            try soapySDR_errToThrow(code: SoapySDRDevice_writeRegister(cDevice, name, addr, value))
        }
    }

    public func readRegister(interface name: String, addr: UInt32) -> UInt32 {
        queue.sync {
            SoapySDRDevice_readRegister(cDevice, name, addr)
        }
    }

    public func writeRegisters(interface name: String, addr: UInt32, values: [UInt32]) throws {
        try queue.sync {
            var valuesCopy = values
            try valuesCopy.withUnsafeMutableBufferPointer {
                try soapySDR_errToThrow(code: SoapySDRDevice_writeRegisters(
                    cDevice,
                    name,
                    addr,
                    $0.baseAddress,
                    numericCast($0.count)
                ))
            }
        }
    }

    public func readRegisters(interface name: String, addr: UInt32, count: Int) -> [UInt32] {
        queue.sync {
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

}
