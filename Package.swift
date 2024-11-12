// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Speak",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "Speak",
            targets: ["Speak"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Boilertalk/Web3.swift.git", from: "0.8.3")
    ],
    targets: [
        .target(
            name: "Speak",
            dependencies: [
                .product(name: "Web3", package: "Web3.swift"),
                .product(name: "Web3ContractABI", package: "Web3.swift"),
                .product(name: "Web3PromiseKit", package: "Web3.swift")
            ]),
        .testTarget(
            name: "SpeakTests",
            dependencies: ["Speak"]),
    ]
)
