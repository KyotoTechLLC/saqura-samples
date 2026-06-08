// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SaQuraSampleApp",
    // The sample uses a few SwiftUI APIs (NavigationSplitView NavigationLink(value:),
    // onChange two-closure form) that require iOS 17 / macOS 14 or newer. The
    // SaQura SDK itself supports iOS 15 / macOS 12.
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
        // SaQura for Swift is distributed as a binary xcframework via saqura.de
        // (no source). SwiftPM resolves it automatically; nothing else to set up.
        .package(
            url: "https://saqura.de/swift/saqura-swift.git",
            from: "1.0.9"
        )
    ],
    targets: [
        .executableTarget(
            name: "SaQuraSampleApp",
            dependencies: [
                .product(name: "SaQura", package: "saqura-swift")
            ],
            path: "SaQuraSampleApp",
            resources: [
                .copy("Resources/Licenses")
            ]
        )
    ]
)
