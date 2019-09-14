// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Checksum",
    platforms: [.macOS(.v10_11), .iOS(.v9), .tvOS(.v9), .watchOS(.v2)],
    products: [
        .library(name: "Checksum", targets: ["Checksum"])
    ],
    dependencies: [],
    targets: [
        .target(name: "Checksum", path: "Source")
    ],
    swiftLanguageVersions: [.v5]
)
