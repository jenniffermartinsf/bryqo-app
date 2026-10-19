// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "BryqoDomain",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "BryqoDomain", targets: ["BryqoDomain"])
    ],
    targets: [
        .target(name: "BryqoDomain"),
        .testTarget(name: "BryqoDomainTests", dependencies: ["BryqoDomain"])
    ]
)
