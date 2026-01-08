//
//  GPIO.swift
//  SoapySDRWrapper
//
//  Created by Connor Gibbons  on 12/3/25.
//

import CSoapySDR

// --- GPIO ---
extension SoapyDevice {

    public func gpioBanks() -> [String] {
        queue.sync {
            var length: size_t = 0
            guard let list = SoapySDRDevice_listGPIOBanks(cDevice, &length) else { return [] }
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

    public func writeGPIO(bank: String, value: UInt32) throws {
        try queue.sync {
            try soapySDR_errToThrow(code: SoapySDRDevice_writeGPIO(cDevice, bank, value))
        }
    }

    public func writeGPIOMasked(bank: String, value: UInt32, mask: UInt32) throws {
        try queue.sync {
            try soapySDR_errToThrow(code: SoapySDRDevice_writeGPIOMasked(cDevice, bank, value, mask))
        }
    }

    public func readGPIO(bank: String) -> UInt32 {
        queue.sync {
            SoapySDRDevice_readGPIO(cDevice, bank)
        }
    }

    public func writeGPIODirection(bank: String, dir: UInt32) throws {
        try queue.sync {
            try soapySDR_errToThrow(code: SoapySDRDevice_writeGPIODir(cDevice, bank, dir))
        }
    }

    public func writeGPIODirectionMasked(bank: String, dir: UInt32, mask: UInt32) throws {
        try queue.sync {
            try soapySDR_errToThrow(code: SoapySDRDevice_writeGPIODirMasked(cDevice, bank, dir, mask))
        }
    }

    public func readGPIODirection(bank: String) -> UInt32 {
        queue.sync {
            SoapySDRDevice_readGPIODir(cDevice, bank)
        }
    }

}

// --- I2C ---
extension SoapyDevice {

    public func writeI2C(addr: Int32, data: [UInt8]) throws {
        try queue.sync {
            let mutable = data.map { Int8(bitPattern: $0) }
            try mutable.withUnsafeBufferPointer {
                try soapySDR_errToThrow(code: SoapySDRDevice_writeI2C(
                    cDevice,
                    addr,
                    UnsafePointer($0.baseAddress),
                    numericCast($0.count)
                ))
            }
        }
    }

    public func readI2C(addr: Int32, numBytes: Int) -> [UInt8] {
        queue.sync {
            var length: size_t = numericCast(numBytes)
            guard let ptr = SoapySDRDevice_readI2C(cDevice, addr, &length) else { return [] }
            let buffer = UnsafeBufferPointer(start: ptr, count: Int(length))
            let result = buffer.map { UInt8(bitPattern: $0) }
            SoapySDR_free(ptr)
            return result
        }
    }

}

// --- SPI ---
extension SoapyDevice {

    public func transactSPI(addr: Int32, data: UInt32, numBits: Int) -> UInt32 {
        queue.sync {
            SoapySDRDevice_transactSPI(cDevice, addr, data, numericCast(numBits))
        }
    }

}

// --- UART ---
extension SoapyDevice {

    public func uarts() -> [String] {
        queue.sync {
            var length: size_t = 0
            guard let list = SoapySDRDevice_listUARTs(cDevice, &length) else { return [] }
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

    public func writeUART(which: String, data: String) throws {
        try queue.sync {
            try soapySDR_errToThrow(code: SoapySDRDevice_writeUART(cDevice, which, data))
        }
    }

    public func readUART(which: String, timeoutUs: Int) -> String? {
        queue.sync {
            guard let ptr = SoapySDRDevice_readUART(cDevice, which, timeoutUs) else { return nil }
            defer { SoapySDR_free(ptr) }
            return String(cString: ptr)
        }
    }

}
