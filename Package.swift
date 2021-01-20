// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "BogusApp-Microservices-ApiGateway",
    platforms: [
       .macOS(.v10_15)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
    ],
    targets: [
        .target(
            name: "Gateway",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
            ],
            path: "Sources/App",
            swiftSettings: [
                // Enable better optimizations when building in Release configuration. Despite the use of
                // the `.unsafeFlags` construct required by SwiftPM, this flag is recommended for Release
                // builds. See <https://github.com/swift-server/guides#building-for-production> for details.
                .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release))
            ]
        ),
        .target(name: "Run Gateway", dependencies: [.target(name: "Gateway")], path: "Sources/Run"),
        .testTarget(
            name: "Gateway Tests",
            dependencies: [
                .target(name: "Gateway"),
                .product(name: "XCTVapor", package: "vapor")
            ],
            path: "Tests/AppTests"
        )
    ]
)
