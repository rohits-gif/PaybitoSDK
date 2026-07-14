// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PayBitoSDK",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "PayBitoSDK",
            type: .dynamic,
            targets: ["PayBitoSDK"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "4.9.1"),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.2"),
        .package(url: "https://github.com/SDWebImage/SDWebImageSwiftUI.git", from: "3.1.4"),
        .package(url: "https://github.com/web3swift-team/web3swift.git", from: "3.3.2"),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "1.10.0"),
        .package(url: "https://github.com/maxdesiatov/XMLCoder.git", from: "0.14.0"),
        .package(url: "https://github.com/weichsel/ZIPFoundation.git", from: "0.9.20"),
        .package(url: "https://github.com/CoreOffice/CoreXLSX", from: "0.14.2")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "PayBitoSDK",
            dependencies: [
                "Alamofire",
                "SwiftyJSON",
                "SDWebImageSwiftUI",
                .product(name: "web3swift", package: "web3swift"),
                "CryptoSwift",
                "XMLCoder",
                "ZIPFoundation",
                "CoreXLSX"
            ],
            path: "PayBitoSDK/Sources/PayBitoSDK",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
