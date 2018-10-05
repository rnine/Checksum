# Checksum

[![Swift](https://img.shields.io/badge/swift-4.2-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![GitHub tag](https://img.shields.io/github/tag/rnine/CryptoHash.svg)](https://github.com/rnine/CryptoHash)
[![License](https://img.shields.io/github/license/mashape/apistatus.svg)](https://github.com/rnine/CryptoHash/blob/develop/LICENSE.md)

Extends `String`, `Data`, and `URL` to easily and efficiently calculate large file content checksums synchronously and asynchronously with optional progress reporting.

#### String

- `checksum(algorithm:)`

#### Data

- `checksum(algorithm:chunkSize:queue:progress:completion:)`

#### URL

- `checksum(algorithm:chunkSize:)`
- `checksum(algorithm:chunkSize:queue:progress:completion:)`

### Supported digests:

- MD5
- SHA1
- SHA224
- SHA256
- SHA384
- SHA512


### Examples

#### Calculating the MD5 checksum of a string:

```swift
let string = "Just a simple string"

// Calculate MD5 checksum
if let checksum = string.checksum(algorithm: .md5) {
    // Use computed checksum
}
```

#### Calculating the MD5 of some data synchronously:

```swift
let data = Data(...) // some data object

// Calculate MD5 checksum
if let checksum = data.checksum(algorithm: .md5) {
    // Use computed checksum
}
```

#### Calculating the MD5 of some data asynchronously with progress reporting:

```swift
let data = Data(...) // some data object

let progress: ProgressHandler = { (bytesProcessed, totalBytes) in
    print("Bytes processed: \(bytesProcessed), bytes total: \(totalBytes), bytes left: \(totalBytes - bytesProcessed)")
}

// Calculate MD5 checksum asynchronously
data.checksum(algorithm: .md5, progress: progress) { (checksum) in
    if let checksum = checksum {
        print("MD5 checksum of \(imageURL) is \(checksum)"
    } else {
        print("Unable to obtain checksum.")
    }
}
```

#### Calculating the SHA256 checksum of a local file synchronously:

```swift
  if let imageURL = Bundle(for: type(of: self)).url(forResource: "image", withExtension: "jpg") {
    // Calculate image SHA256 checksum
    if let checksum = imageURL.checksum(algorithm: .sha256) {
        // Use computed checksum
    }
  }
```

#### Calculating the SHA256 checksum of a remote file asynchronously with progress reporting:

```swift
  let progress: ProgressHandler = { (bytesProcessed, totalBytes) in
      print("Bytes processed: \(bytesProcessed), bytes total: \(totalBytes), bytes left: \(totalBytes - bytesProcessed)")
  }

  if let imageURL = URL(string: "https://github.com/rnine/Checksum/raw/master/ChecksumTests/Fixtures/image.jpg") {
      // Calculate image SHA256 checksum asynchronously with progress reporting
      imageURL.checksum(algorithm: .sha256, progress: progress) { (checksum) in
          if let checksum = checksum {
            print("SHA256 checksum of \(imageURL) is \(checksum)"
          } else {
            print("Unable to obtain checksum.")
          }
      }
  }
```

### Requirements

- Xcode 10 and Swift 4.2

### License

`Checksum` was written by Ruben Nine ([@sonicbee9](https://twitter.com/sonicbee9)) and is licensed under the [MIT](http://opensource.org/licenses/MIT) license. See [LICENSE.md](LICENSE.md).
