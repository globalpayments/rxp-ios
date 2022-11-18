// swift-tools-version:5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.


import PackageDescription


let package = Package(
    name: "RXPiOS",
    platforms: [.iOS(.v9)],
    products: [
        .library(
            name: "RXPiOS",
            targets: ["RXPiOS"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "RXPiOS",
            dependencies: [ ],
            path: "Pod/Classes"
        ),
    ]
)
