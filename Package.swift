// swift-tools-version: 6.1
// This is a Skip (https://skip.tools) package.
import PackageDescription

let package = Package(
    name: "pick-android-admin",
    defaultLocalization: "en",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "PiCKAdmin", type: .dynamic, targets: ["PiCKAdmin"]),
    ],
    dependencies: [
        .package(url: "https://source.skip.tools/skip.git", exact: "1.7.0"),
        .package(url: "https://source.skip.tools/skip-fuse-ui.git", exact: "1.12.0")
    ],
    targets: [
        .target(name: "PiCKAdmin", dependencies: [
            .product(name: "SkipFuseUI", package: "skip-fuse-ui")
        ], resources: [.process("Resources")], plugins: [.plugin(name: "skipstone", package: "skip")]),
    ]
)
