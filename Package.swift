// swift-tools-version: 6.3

import PackageDescription

// Plain values, no UI framework: builds on Linux, Windows and Android.
let tokens: [Target] = [
    .target(name: "VitralTokens"),
    .testTarget(name: "VitralTokensTests", dependencies: ["VitralTokens"])
]

// SwiftUI components on the tokens: Apple platforms only, so left out elsewhere.
#if canImport(Darwin)
let components: [Target] = [.target(name: "Vitral", dependencies: ["VitralTokens"], resources: [.process("Resources")])]
let componentProducts: [Product] = [.library(name: "Vitral", targets: ["Vitral"])]
#else
let components: [Target] = []
let componentProducts: [Product] = []
#endif

let package = Package(
    name: "Vitral",
    platforms: [.iOS(.v26), .macOS(.v26)],
    products: [.library(name: "VitralTokens", targets: ["VitralTokens"])] + componentProducts,
    targets: tokens + components
)
