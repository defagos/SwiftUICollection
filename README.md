# Building a Collection For SwiftUI - Sample Code

This is the sample code for my [_Building a Collection For SwiftUI_](http://defagos.github.io/swiftui_collection_intro) article series.

It contains:

- A Swift package with a collection for SwiftUI.
- A sample project.

This collection intends to solve performance issues associated with SwiftUI stack and scroll view nesting, especially on tvOS. It achieves this results by wrapping `UICollectionView` internally.

## Purpose

This code is a companion to the aforementioned article. It should not be used as a library. The Swift package is intended for experimental use in custom projects.

## Requirements

This project must be compiled with Xcode 12.

## Compatibility

The package is compatible with iOS and tvOS 13 and above. The example project runs on iOS and tvOS 14 and above.

## License

See the [LICENSE](../LICENSE) file for more information.