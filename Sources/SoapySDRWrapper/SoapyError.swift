import CSoapySDR

public enum SoapyError: Error {
    case timeout
    case streamError
    case corruption
    case overflow
    case notSupported
    case timeError
    case underflow
    case badApi
    case apiVersion
    case runtime
    case memory
    case badReturn
    case badHandle
    case notReady
    case invalidArgument
    case deviceNotOpen
    case unknown
    
    init(code: Int32) {
        switch code {
        case SOAPY_SDR_TIMEOUT:
            self = .timeout
        case SOAPY_SDR_STREAM_ERROR:
            self = .streamError
        case SOAPY_SDR_CORRUPTION:
            self = .corruption
        case SOAPY_SDR_OVERFLOW:
            self = .overflow
        case SOAPY_SDR_NOT_SUPPORTED:
            self = .notSupported
        case SOAPY_SDR_TIME_ERROR:
            self = .timeError
        case SOAPY_SDR_UNDERFLOW:
            self = .underflow
        default:
            self = .unknown
        }
    }
}

public func SoapySDR_errToStr(errorCode: Int32) -> String {
    return String(cString: CSoapySDR.SoapySDR_errToStr(errorCode))
}

func soapySDR_errToThrow(code: Int32) throws {
    if code != 0 {
        throw SoapyError(code: code)
    }
}
