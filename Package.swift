// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "RoasterHammer",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.1.0"),

        // 🔵 Swift ORM (queries, models, relations, etc) built on PostgreSQL.
        .package(url: "https://github.com/vapor/fluent-postgresql.git", from: "1.0.0"),

        // Swift package to handle authentication.
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.1"),

        // Web templating language framework package
        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.2"),

        .package(url: "https://github.com/klein-thibault/RoasterHammer-Shared.git", from: "0.0.6")

        // Neo4j Database client
        // .package(url: "https://github.com/Neo4j-Swift/Neo4j-Swift.git", from: "4.0.2")
    ],
    targets: [
        //.target(name: "App", dependencies: ["FluentPostgreSQL", "Vapor", "Authentication", "Leaf", "RoasterHammer-Shared", "Theo"]),
        .target(name: "App", dependencies: ["FluentPostgreSQL", "Vapor", "Authentication", "Leaf", "RoasterHammer-Shared"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

