// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "whatnext",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .executable(
            name: "whatnext",
            targets: ["whatnext"]),
    ],
    dependencies: [
        // List your project dependencies here, if any.
        // .package(url: "https://github.com/some/Dependency.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "whatnext",
            dependencies: []),
        .testTarget(
            name: "whatnextTests",
            dependencies: ["whatnext"]),
    ]
)
