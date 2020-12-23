// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "composable-multipeer-connectivity",
  platforms: [
    .iOS(.v13),
    .macOS(.v10_15)
  ],
  products: [
    .library(
      name: "ComposableMultipeerConnectivity",
      targets: ["ComposableMultipeerConnectivity"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.9.0"),
  ],
  targets: [
    .target(
      name: "ComposableMultipeerConnectivity",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
      ]
    ),
    .testTarget(
      name: "ComposableMultipeerConnectivityTests",
      dependencies: ["ComposableMultipeerConnectivity"]),
  ]
)
