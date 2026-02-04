//
//  SoapyDevice.swift
//  SoapySDRWrapper
//
//  Created by Connor Gibbons  on 11/25/25.
//
import Foundation
import CSoapySDR

public class SoapyDevice {
    public let cDevice: OpaquePointer

    // --- Thread Safety ---
    internal let queue = DispatchQueue(label: "com.soapysdr.device.serialqueue")

    // --- Async Read Management ---
    func getNextAsyncHandlerId() -> Int {
        defer { self.nextAsyncHandlerId += 1 }
        return self.nextAsyncHandlerId
    }
    private var nextAsyncHandlerId: Int = 0
    var asyncHandlerDictionary: [Int: AsyncHandler] = [:]
    public var isActive: Bool {
        return !asyncHandlerDictionary.isEmpty
    }
    
    // --- Native Handle ---
    public var nativeHandle: UnsafeMutableRawPointer? {
        queue.sync {
            SoapySDRDevice_getNativeDeviceHandle(cDevice)
        }
    }
    
    public var description: String {
        var output = "--- SoapyDevice: \(self.driverName ?? "Unknown") (\(self.hardwareName ?? "Unknown")) ---\n\n"
        
        output += "[METADATA]\n"
        output += "Hardware Kwargs: \(self.hardwareKwargs.description)\n\n"
        
        output += "[GENERAL]\n"
        
        output += "--- IO ---\n"
        let gpioString = self.gpioBanks().isEmpty ? "None" : self.gpioBanks().joined(separator: ",")
        output += "  GPIO: \(gpioString)\n"
        let uartString = self.uarts().isEmpty ? "None" : self.uarts().joined(separator: ",")
        output += "  UART: \(uartString)\n"
        output += "\n"
        
        output += "--- Registers ---\n"
        let registersString = self.registerInterfaces().isEmpty ? "None" : self.registerInterfaces().joined(separator: ",")
        output += "  Registers: \(registersString)\n"
        output += "\n"
        
        output += "--- Clock Sources ---\n"
        let clockSourcesString = self.clockSources().isEmpty ? "None" : self.clockSources().joined(separator: ",")
        output += "  Clock Sources: \(clockSourcesString)\n"
        if let source = self.clockSource { output += "  Current Source: \(source == "" ? "None" : source)\n" }
        output += "\n"
        
        output += "--- Time Sources ---\n"
        let timeSourcesString = self.timeSources().isEmpty ? "None" : self.clockSources().joined(separator: ",")
        output += "  Time Sources: \(timeSourcesString)\n"
        if let timeSource = self.timeSource {
            output += "  Current Source: \(timeSource == "" ? "None" : timeSource)\n"
            if timeSource != "" {
                output += "  Current Time: \(self.hardwareTime(what: timeSource))\n"
            }
        }
        output += "\n"
        
        output += "--- Sensors ---\n"
        let sensorsString = self.sensors().isEmpty ? "None" : self.sensors().joined(separator: ",")
        output += "  Sensors: \(sensorsString)\n"
        
        
        output += "[CHANNELS]\n"
        output += "RX: \(self.rxNumChannels) | TX: \(self.txNumChannels)\n\n"

        func buildChannelString(isRx: Bool, channel: Int) -> String {
            var str = ""
            let direction: SoapyDirection = isRx ? .rx : .tx
            // --- General Info ---
            let info = isRx ? self.rxChannelInfo(channel: channel) : self.txChannelInfo(channel: channel)
            let isDuplex = isRx ? self.rxIsFullDuplex(channel: channel) : self.txIsFullDuplex(channel: channel)
            let antennas = self.antennas(direction: direction, channel: channel)
            
            if !info.description.isEmpty && info.description != "SoapyKwargs: empty" {
                str += "    Info:         \(info.description)\n"
            }
            str += "  Antenna:      \(antennas.joined(separator: ", "))\n"
            str += "  Full Duplex:  \(isDuplex)\n\n"

            // --- Frequencies ---
            str += "  -- Frequency --\n"
            let currentFreq = self.frequency(direction: direction, channel: channel)
            let ranges = self.frequencyRange(direction: direction, channel: channel)
            
            str += "  Current:      \(Frequency(hz: currentFreq).description(unit: .mhz))\n"
            str += "  Range:        \(ranges.map { $0.descriptionWithFrequencyUnits }.joined(separator: " / "))\n"
            
            let components = self.frequencyElements(direction: direction, channel: channel)
            if !components.isEmpty {
                str += "  Tunable Elements:\n"
                let elementDict: [String: String] = ["CORR": "Correction", "RF": "RF Frontend", "BB": "Baseband"]
                
                for comp in components {
                    let compFreq = self.frequencyComponent(direction: direction, channel: channel, name: comp)
                    let compRanges = self.frequencyRange(direction: direction, channel: channel, element: comp)
                    let prettyName = elementDict[comp] ?? comp
                    if(prettyName == "Correction") {
                        str += "    * \(prettyName): \(compFreq) ppm\n"
                        str += "      (Range (ppm): \(compRanges.map { $0.description }.joined(separator: ", ")))\n"
                    }
                    else if(prettyName == "RF Frontend") {
                        str += "    * \(prettyName): \(Frequency(hz: compFreq).description(unit: .mhz))\n"
                        str += "      (Range: \(compRanges.map { $0.descriptionWithFrequencyUnits }.joined(separator: ", ")))\n"
                    }
                    else {
                        str += "      (Range: \(compRanges.map { $0.description }.joined(separator: ", ")))\n"
                    }
                }
            }
            str += "\n"

            // --- Gain ---
            str += "  -- Gain --\n"
            let hasAgc = self.hasGainMode(direction: direction, channel: channel)
            let agcEnabled = self.gainMode(direction: direction, channel: channel)
            let totalGain = self.gain(direction: direction, channel: channel)
            let totalRange = self.gainRange(direction: direction, channel: channel)
            
            str += "  Mode:         \(hasAgc ? (agcEnabled ? "Automatic" : "Manual (AGC Supported)") : "Manual Only")\n"
            str += "  Total Gain:   \(totalGain) (Range: \(totalRange.description))\n"
            
            let gainElements = self.gainElements(direction: direction, channel: channel)
            if !gainElements.isEmpty {
                str += "  Elements:\n"
                for element in gainElements {
                    let elGain = self.gain(direction: direction, channel: channel, element: element)
                    let elRange = self.gainElementRange(direction: direction, channel: channel, element: element)
                    str += "    * \(element): \(elGain) (Range: \(elRange.description))\n"
                }
            }
            str += "\n"

            // --- Sample Rate & Bandwidth ---
            str += "  -- Sample Rate & Bandwidth --\n"
            let rate = self.sampleRate(direction: direction, channel: channel)
            let bw = self.bandwidth(direction: direction, channel: channel)
            let rateRanges = self.sampleRateRanges(direction: direction, channel: channel)
            let bwRanges = self.bandwidthRanges(direction: direction, channel: channel)
            
            str += "  Rate:         \(rate)\n"
            str += "  Bandwidth:    \(Frequency(hz:bw).description(unit: .mhz)) (Range: \(bwRanges.map { $0.descriptionWithFrequencyUnits }.joined(separator: ", ")))\n"
            str += "  Supported Rates:\n"
            for range in rateRanges {
                str += "    * \(range.description)\n"
            }
            str += "\n"

            // --- Corrections ---
            str += "  -- Corrections --\n"
            
            // DC Offset
            let hasDC = self.hasDCOffset(direction: direction, channel: channel)
            if hasDC {
                do {
                    let dcVal = try self.dcOffset(direction: direction, channel: channel)
                    let autoDC = self.dcOffsetMode(direction: direction, channel: channel)
                    str += "  DC Offset:    \(autoDC ? "Automatic" : "Manual") -> \(String(describing: dcVal))\n"
                }
                catch {
                    print("Error: \(error.localizedDescription)")
                }
            } else {
                str += "  DC Offset:    Not Supported\n"
            }
            
            // IQ Balance
            let hasIQ = self.hasIQBalance(direction: direction, channel: channel)
            if hasIQ {
                let iqVal = self.iqBalance(direction: direction, channel: channel)
                let autoIQ = self.iqBalanceMode(direction: direction, channel: channel)
                str += "  IQ Balance:   \(autoIQ ? "Automatic" : "Manual") -> \(String(describing: iqVal))\n"
            } else {
                str += "  IQ Balance:   Not Supported\n"
            }
            
            return str
        }
        
        for rxChannel in 0..<self.rxNumChannels {
            output += "[RX CHANNEL \(rxChannel)]\n"
            output += buildChannelString(isRx: true, channel: rxChannel)
            output += "\n"
        }
        
        for txChannel in 0..<self.txNumChannels {
            output += "[TX CHANNEL \(txChannel)]\n"
            output += buildChannelString(isRx: false, channel: txChannel)
            output += "\n"
        }

        output += "--------------------------------"
        return output
    }
    
    // --- Init / Deinit ---
    public init(kwargs: SoapyKwargs) throws {
        let cKwargPointer = kwargs.getcKwargsMutablePointer()
        defer { cKwargPointer.deallocate() }

        guard let devicePtr = SoapySDRDevice_make(cKwargPointer) else {
            print("SoapySDRWrapper: Failed to create SoapySDRDevice.")
            throw SoapyError.deviceNotOpen
        }
        self.cDevice = devicePtr

        queue.sync {
            if deviceCache.deviceIsPresent(devicePtr) {
                print("SoapySDRWrapper warning: Device already present in cache, this SoapyDevice will refer to the same SDR as an existing SoapyDevice.")
            }
            deviceCache.addDevice(devicePtr)
        }
    }
    
    public init(stringArgs: String) throws {
        var devicePtr: OpaquePointer?
        try stringArgs.utf8CString.withUnsafeBufferPointer { cStringBufferPtr in // UnsafeBufferPointer<CChar>
            guard let devPtr = SoapySDRDevice_makeStrArgs(cStringBufferPtr.baseAddress) else {
                throw SoapyError.deviceNotOpen
            }
            devicePtr = devPtr
        }
        guard let devicePtr else {
            throw SoapyError.deviceNotOpen
        }
        self.cDevice = devicePtr
        queue.sync {
            if deviceCache.deviceIsPresent(devicePtr) {
                print("SoapySDRWrapper warning: Device already present in cache, this SoapyDevice will refer to the same SDR as an existing SoapyDevice.")
            }
            deviceCache.addDevice(devicePtr)
        }
    }
    
    public convenience init(int: Int) throws {
        guard int >= 0 && int < deviceCache.potentialDevices.count else { throw SoapyError.deviceNotOpen }
        try self.init(kwargs: deviceCache.potentialDevices[int])
    }
    
    deinit {
        queue.sync {
            deviceCache.removeDevice(cDevice)
            SoapySDRDevice_unmake(cDevice)
        }
    }
}

// --- Global Device Status Helpers ---
extension SoapyDevice {
    
    public static func lastStatus() -> SoapyError {
        return SoapyError(code: SoapySDRDevice_lastStatus())
    }
    
    public static func lastError() -> String? {
        guard let ptr = SoapySDRDevice_lastError() else { return nil }
        // Do NOT free lastError, it is internal thread-local storage.
        return String(cString: ptr)
    }
    
}
