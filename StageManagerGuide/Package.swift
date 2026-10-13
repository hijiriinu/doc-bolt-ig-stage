// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "StageManagerGuide",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "StageManagerGuide",
            path: "Sources/StageManagerGuide"
        )
    ]
)
