// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "VaporOAuthFluent",
    products: [
        .library(name: "VaporOAuthFluent", targets: ["VaporOAuthFluent"]),
    ],
    dependencies: [
    	.package(url: "https://github.com/vapor/vapor.git", .upToNextMajor(from: "2.2.0")),
        .package(url: "https://github.com/vapor/fluent-provider.git", .upToNextMajor(from: "1.2.0")),
        .package(url: "https://github.com/brokenhandsio/vapor-oauth.git", .upToNextMajor(from: "0.6.0")),
    ],
    targets: [
        .target(name: "VaporOAuthFluent", dependencies: ["Vapor", "VaporOAuth", "FluentProvider"]),
        .testTarget(name: "VaporOAuthFluentTests", dependencies: ["VaporOAuthFluent"]),
    ]
)
