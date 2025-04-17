// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FeatureVote",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "FeatureVote",
            targets: ["FeatureVote"]),
    ],
    targets: [
        .target(
            name: "FeatureVote",
            resources: []
        )
    ]
)
