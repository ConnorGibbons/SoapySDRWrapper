//
//  Types.swift
//  SoapySDRWrapper
//
//  Created by Connor Gibbons  on 11/25/25.
//
import Foundation
import CSoapySDR

enum SoapyDirection: Int32 {
    case rx = 1
    case tx = 0
}

enum SoapySDRWrapperErrors: Error {
    case deviceInitFailed
}

extension SoapySDRRange {
    var description: String {
        "Min: \(self.minimum), Max: \(self.maximum), Step: \(self.step)"
    }
    
    /// Useful for presentation if the range is describing values in Hz.
    var descriptionWithFrequencyUnits: String {
        let minAsFrequency = Frequency(hz: self.minimum)
        let maxAsFrequency = Frequency(hz: self.maximum)
        let stepAsFrequency = Frequency(hz: self.step)
        return "Min: \(minAsFrequency.description(unit: .mhz)), Max: \(maxAsFrequency.description(unit: .mhz)), Step: \(stepAsFrequency.description(unit: .hz))"
    }
}

struct SoapyKwargs {
    var dict: [String: String]
    var cKwargs: SoapySDRKwargs
    
    init(cKwargs: SoapySDRKwargs) {
        self.dict = [:]
        self.cKwargs = cKwargs
        for i in 0..<cKwargs.size {
            guard let keyPtr = cKwargs.keys[i], let valPtr = cKwargs.vals[i] else { continue }
            let key = String(cString: keyPtr); let val = String(cString: valPtr)
            dict.updateValue(val, forKey: key)
        }
    }
    
    /// Gets a mutable pointer to a copy of cKwargs. Don't forget to deallocate after use.
    func getcKwargsMutablePointer() -> UnsafeMutablePointer<SoapySDRKwargs> {
        return getMutablePointerForValue(value: cKwargs)
    }
    
    var description: String {
        guard dict.isEmpty else { return "SoapyKwargs: empty\n"}
        var desc = "SoapyKwargs:\n"
        for (k, v) in dict {
            desc += "\(k) = \(v)\n"
        }
        return desc
    }
}




// Units

enum frequencyUnit: Double {
    case hz = 1.0
    case khz = 1e-3
    case mhz = 1e-6
    case ghz = 1e-9
}

struct Frequency: Equatable {
    var hz: Double
    
    init(hz: Double) {
        self.hz = hz
    }
    
    init(value: Double, unit: frequencyUnit) {
        self.hz = value * unit.rawValue
    }
    
    func getAsUnit(_ unit: frequencyUnit) -> Double {
        return hz * unit.rawValue
    }
    
    func description(unit: frequencyUnit) -> String {
        let unitString = switch unit {
        case .hz: "Hz"
        case .khz: "kHz"
        case .mhz: "MHz"
        case .ghz: "GHz"
        }
        
        return "\(String(format: "%.4f", getAsUnit(unit))) \(unitString)"
    }
    
    static func == (lhs: Frequency, rhs: Frequency) -> Bool {
        return lhs.hz == rhs.hz
    }
}
