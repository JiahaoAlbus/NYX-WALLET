// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "NYXWallet",
    platforms: [
        .iOS(.v17),
        .macOS(.v12)
    ],
    products: [
        .library(name: "NYXCore", targets: ["NYXCore"]),
        .library(name: "NYXSecurity", targets: ["NYXSecurity"]),
        .library(name: "NYXRisk", targets: ["NYXRisk"]),
        .library(name: "NYXChains", targets: ["NYXChains"]),
        .library(name: "NYXUI", targets: ["NYXUI"]),
        .executable(name: "NYXWalletApp", targets: ["NYXWalletApp"]) 
    ],
    dependencies: [
        .package(url: "https://github.com/trustwallet/wallet-core", branch: "master"),
        .package(url: "https://github.com/attaswift/BigInt.git", from: "5.7.0")
    ],
    targets: [
        .target(
            name: "NYXCore",
            dependencies: []
        ),
        .target(
            name: "NYXSecurity",
            dependencies: [
                "NYXCore",
                .product(name: "WalletCore", package: "wallet-core"),
                .product(name: "WalletCoreSwiftProtobuf", package: "wallet-core")
            ]
        ),
        .target(
            name: "NYXRisk",
            dependencies: ["NYXCore"]
        ),
        .target(
            name: "NYXChains",
            dependencies: [
                "NYXCore",
                "NYXSecurity",
                "NYXRisk",
                "BigInt",
                .product(name: "WalletCore", package: "wallet-core"),
                .product(name: "WalletCoreSwiftProtobuf", package: "wallet-core")
            ]
        ),
        .target(
            name: "NYXUI",
            dependencies: [
                "NYXCore",
                "NYXChains",
                "NYXSecurity",
                "NYXRisk"
            ]
        ),
        .executableTarget(
            name: "NYXWalletApp",
            dependencies: ["NYXUI"]
        ),
        .testTarget(
            name: "NYXCoreTests",
            dependencies: ["NYXCore", "NYXChains", "NYXSecurity"]
        )
    ]
)
