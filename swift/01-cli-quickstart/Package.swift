// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CliQuickstart",
    platforms: [
        .macOS(.v12)
    ],
    dependencies: [
        // SaQura for Swift is distributed as a binary xcframework via saqura.de
        // (no source). SwiftPM resolves it automatically; nothing else to set up.
        .package(
            url: "https://saqura.de/swift/saqura-swift.git",
            from: "1.0.9"
        )
    ],
    targets: [
        .executableTarget(
            name: "CliQuickstart",
            dependencies: [
                .product(name: "SaQura", package: "saqura-swift")
            ],
            path: "Sources"
        )
    ]
)
