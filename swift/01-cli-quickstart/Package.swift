// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CliQuickstart",
    platforms: [
        .macOS(.v12)
    ],
    dependencies: [
        // After SaQuraSwift is published on GitHub, this resolves automatically.
        // For local development, swap for: .package(path: "../../../SaQuraSwift")
        .package(
            url: "https://github.com/KyotoTechLLC/SaQuraSwift.git",
            from: "1.0.0"
        )
    ],
    targets: [
        .executableTarget(
            name: "CliQuickstart",
            dependencies: [
                .product(name: "SaQura", package: "SaQuraSwift")
            ],
            path: "Sources"
        )
    ]
)
