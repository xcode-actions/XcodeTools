// swift-tools-version:5.5
import PackageDescription



let package = Package(
	name: "DifferentName",
	products: [
		.library(name: "GAmazingLib3", targets: ["GAmazingLib3"])
	],
	targets: [
		.target(name: "GAmazingLib3")
	]
)
