// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Ghostinote",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "Ghostinote", targets: ["Ghostinote"])
    ],
    targets: [
        .executableTarget(
            name: "Ghostinote",
            path: "Sources/Ghostinote"
        ),
        .testTarget(
            name: "GhostinoteTests",
            dependencies: ["Ghostinote"],
            path: "Tests/GhostinoteTests"
        )
    ]
)
