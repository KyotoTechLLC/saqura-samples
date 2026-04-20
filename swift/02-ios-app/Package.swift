// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SaQuraSampleApp",
    // The sample uses a few SwiftUI APIs (NavigationSplitView NavigationLink(value:),
    // onChange two-closure form) that require iOS 17 / macOS 14 or newer. The
    // SaQuraSwift SDK itself supports iOS 15 / macOS 12.
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "SaQuraSampleApp",
            targets: ["SaQuraSampleApp"]
        )
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
            name: "SaQuraSampleApp",
            dependencies: [
                .product(name: "SaQura", package: "SaQuraSwift")
            ],
            path: "SaQuraSampleApp",
            resources: [
                .copy("Resources/Licenses")
            ]
        )
    ]
)
