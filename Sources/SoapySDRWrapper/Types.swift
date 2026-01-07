//
//  Types.swift
//  SoapySDRWrapper
//
//  Created by Connor Gibbons  on 11/25/25.
//
import Foundation
import CSoapySDR

public enum SoapyDirection: Int32 {
    case rx = 1
    case tx = 0
}

public enum SoapySDRWrapperErrors: Error {
    case deviceInitFailed
}

public extension SoapySDRRange {
    public var description: String {
        "Min: \(self.minimum), Max: \(self.maximum), Step: \(self.step)"
    }
    
    /// Useful for presentation if the range is describing values in Hz.
    public var descriptionWithFrequencyUnits: String {
        let minAsFrequency = Frequency(hz: self.minimum)
        let maxAsFrequency = Frequency(hz: self.maximum)
        let stepAsFrequency = Frequency(hz: self.step)
        return "Min: \(minAsFrequency.description(unit: .mhz)), Max: \(maxAsFrequency.description(unit: .mhz)), Step: \(stepAsFrequency.description(unit: .hz))"
    }
}

public struct SoapyKwargs {
    public var dict: [String: String]
    var cKwargs: SoapySDRKwargs
    
    public init(cKwargs: SoapySDRKwargs) {
        self.dict = [:]
        self.cKwargs = cKwargs
        for i in 0..<cKwargs.size {
            guard let keyPtr = cKwargs.keys[i], let valPtr = cKwargs.vals[i] else { continue }
            let key = String(cString: keyPtr); let val = String(cString: valPtr)
            dict.updateValue(val, forKey: key)
        }
    }
    
    /// Gets a mutable pointer to a copy of cKwargs. Don't forget to deallocate after use.
    public func getcKwargsMutablePointer() -> UnsafeMutablePointer<SoapySDRKwargs> {
        return getMutablePointerForValue(value: cKwargs)
    }
    
    public var description: String {
        guard !dict.isEmpty else { return "(Empty SoapyKwargs)\n"}
        var desc = "SoapyKwargs:\n"
        for (k, v) in dict {
            desc += "\(k) = \(v)\n"
        }
        return desc
    }
}




// Units

public enum frequencyUnit: Double {
    case hz = 1.0
    case khz = 1e-3
    case mhz = 1e-6
    case ghz = 1e-9
}

public struct Frequency: Equatable {
    var hz: Double
    
    public init(hz: Double) {
        self.hz = hz
    }
    
    public init(value: Double, unit: frequencyUnit) {
        self.hz = value * unit.rawValue
    }
    
    public func getAsUnit(_ unit: frequencyUnit) -> Double {
        return hz * unit.rawValue
    }
    
    public func description(unit: frequencyUnit) -> String {
        let unitString = switch unit {
        case .hz: "Hz"
        case .khz: "kHz"
        case .mhz: "MHz"
        case .ghz: "GHz"
        }
        
        return "\(String(format: "%.4f", getAsUnit(unit))) \(unitString)"
    }

    public static func == (lhs: Frequency, rhs: Frequency) -> Bool {
        return lhs.hz == rhs.hz
    }
}
