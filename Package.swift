// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SoapySDRWrapper",
    products: [
        .library(name: "SoapySDRWrapper", targets: ["SoapySDRWrapper"]),
    ],
    targets: [
        .target(name: "SoapySDRWrapper", dependencies: ["CSoapySDR"]),
        .testTarget(
            name: "SoapySDRWrapperTests",
            dependencies: ["SoapySDRWrapper"]
        ),
        .systemLibrary(name: "CSoapySDR", pkgConfig: "soapysdr", providers: [.brew(["soapysdr"])])
    ]
)
