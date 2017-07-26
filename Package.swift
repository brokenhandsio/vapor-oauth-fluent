import PackageDescription

let package = Package(
    name: "vapor-oauth-fluent",
    dependencies: [
    	.Package(url: "https://github.com/vapor/fluent-provider.git", majorVersion: 1),
    	.Package(url: "https://github.com/brokenhandsio/vapor-oauth.git", majorVersion: 0),
    ]
)
