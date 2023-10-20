// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PunkLang",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(name: "MonadicParsing", targets: ["MonadicParsing"]),
        .library(name: "PrettyTree", targets: ["PrettyTree"]),
        .library(name: "PunkLang", targets: ["PunkLang"]),
        .library(name: "PunkLangParser", targets: ["PunkLangParser"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(
            url: "https://github.com/apple/swift-collections.git",
            .upToNextMinor(from: "1.0.0")
        )
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(name: "MonadicParsing"),
        .target(name: "PrettyTree", dependencies: [.product(name: "Collections", package: "swift-collections")]),
        .target(name: "PunkLangParser", dependencies: ["MonadicParsing", "PrettyTree"]),
        .target(name: "PunkLang", dependencies: ["PunkLangParser"]),
        .executableTarget(name: "PunkLangCLI", dependencies: ["MonadicParsing", "PrettyTree", "PunkLangParser", "PunkLang"]),
//        .testTarget(name: "PunkLangTests", dependencies: ["PunkLang"]),
    ]
)


