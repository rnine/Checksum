# Checksum

[![Platform](https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS%20%7C%20watchOS%20%7C%20tvOS%20-4E4E4E.svg?colorA=28a745)](https://github.com/rnine/Checksum)
[![Swift support](https://img.shields.io/badge/Swift-5.0%20%7C%205.1%20-lightgrey.svg?colorA=28a745&colorB=4E4E4E)](https://github.com/rnine/Checksum)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-brightgreen.svg?style=flat&colorA=28a745&&colorB=4E4E4E)](https://github.com/Carthage/Carthage)
[![Swift Package Manager compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg?style=flat&colorA=28a745&&colorB=4E4E4E)](https://github.com/apple/swift-package-manager)

[![GitHub tag](https://img.shields.io/github/tag/rnine/Checksum.svg)](https://github.com/rnine/Checksum)
[![License](https://img.shields.io/github/license/mashape/apistatus.svg)](https://github.com/rnine/Checksum/blob/develop/LICENSE.md)

Extends `String`, `Data`, and `URL` adding the ability to easily and efficiently calculate the cryptographic checksum of its associated
contents by adding conformance to the `Checksumable` protocol. 

Under the hood, Apple's `CommonCrypto` framework is used.

### Features

#### Supported Digests

`MD5`, `SHA1`, `SHA224`, `SHA256`, `SHA384`, `SHA512`

#### Async Processing

Processing and progress monitoring are performed asynchronously on a background dispatch queue. Progress and completion 
closures are, by default, called on the `.main` dispatch queue. However, a different `DispatchQueue` may be specified.

The function signature for async processing is: 

- `checksum(algorithm:chunkSize:queue:progress:completion:)`

#### Sync Processing

In the cases where the payload is fairly small, asynchronous processing may not be required or desirable. For such cases, a synchronous 
version is provided.

The function signature for sync processing is:

- `checksum(algorithm:chunkSize:)`

#### Process Local or Remote URLs

Any URLs with schemes `file`, `http`, or `https` may be used as input. However, `http` and `https` support is currently ***experimental*** and has the following requirements: 

1. The HTTP server must be able to respond to `HEAD` requests in order to determine whether the `URL` is reachable.
2. The HTTP server must be able to serve [206 Partial Content](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/206) responses.

#### Batch Processing

Support for processing arrays of  `Checksumable` items is also included and showcased in the examples below.

### Examples

#### Calculating the checksum of some `Data` asynchronously

```swift
data.checksum(algorithm: .md5) { result in
    switch result {
    case .success(let checksum):
        // Use checksum
    case .failure(let error):
        // Unable to obtain checksum
    }
}
```
#### Calculating the checksum of the content at a given `URL` asynchronously

```swift
remoteURL.checksum(algorithm: .sha256) { result in
    switch result {
    case .success(let checksum):
        // Use checksum
    case .failure(let error):
        // Unable to obtain checksum
    }
}
```
#### Calculating the checksums of the contents at given `URLs` asynchronously

```swift
[someURL, anotherURL, yetAnotherURL].checksum(algorithm: .md5) { result in
    switch result {
    case .success(let checksumResults):
        // Use results object
        
        for checksumResult in checksumResults {
            guard let url = checksumResult.checksumable as? URL else {
                fail("Expected checksumable to be of type URL.")
                return
            }
            
            if let checksum = checksumResult.checksum {
                print("Checksum of \(result.checksumable) is \(checksumResult.checksum)")
            } else {
                print("Unable to obtain checksum for \(checksumResult.checksumable)")
            }
        }
    case .failure(let error):
        // Unable to obtain checksums
    }
}
```

#### Calculating the checksum of some `String` synchronously

```swift
if let checksum = string.checksum(algorithm: .md5) {
    // Use checksum
}
```

#### Calculating the checksum of some `Data` synchronously

```swift
if let checksum = data.checksum(algorithm: .md5) {
    // Use checksum
}
```

#### Calculating the checksum of the content at a given `URL` synchronously

```swift
if let checksum = localURL.checksum(algorithm: .md5) {
    // Use checksum
}
```

### Progress Reporting

You may monitor progress by passing a `ProgressHandler` closure to the `progress` argument in 
`checksum(algorithm:chunkSize:queue:progress:completion:)`.

#### Example

```swift
remoteURL.checksum(algorithm: .sha256, progress: { progress in
    // Add your progress handling code here.
    print("Fraction completed: \(progress.fractionCompleted)")
}) { result in 
    /// Result handling ommited.
}
```

### Requirements

- Xcode 10.2 and Swift 5.0

### License

`Checksum` was written by Ruben Nine ([@sonicbee9](https://twitter.com/sonicbee9)) and is licensed under the 
[MIT](http://opensource.org/licenses/MIT) license. See [LICENSE.md](LICENSE.md).
