// swift-tools-version:5.5

/**
*  CollectionConcurrencyKit
*  Copyright (c) John Sundell 2021
*  MIT license, see LICENSE.md file for details
*/

import PackageDescription

let package = Package(
    name: "CollectionConcurrencyKit",
    products: [
        .library(
            name: "CollectionConcurrencyKit",
            targets: ["CollectionConcurrencyKit"]
        )
    ],
    targets: [
        .target(
            name: "CollectionConcurrencyKit",
            path: "Sources"
        ),
        .testTarget(
            name: "CollectionConcurrencyKitTests",
            dependencies: ["CollectionConcurrencyKit"],
            path: "Tests"
        )
    ]
)
