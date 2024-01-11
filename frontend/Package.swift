// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "whatnext",
    platforms: [
        .iOS(.v14) // Specify the minimum iOS version you are targeting
    ],
    products: [
        .executable(
            name: "whatnext",
            targets: ["whatnext"]),
    ],
    dependencies: [
        // Add your project dependencies here, if any.
        // .package(url: "https://github.com/some/Dependency.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "whatnext",
            dependencies: [],
            path: "whatnext"
        ),
        .testTarget(
            name: "whatnextTests",
            dependencies: ["whatnext"],
            path: "Tests"
        ),
        .testTarget(
            name: "whatnextUITests",
            dependencies: ["whatnext"],
            path: "UITests"
        ),
    ]
)
