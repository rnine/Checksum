# Checksum

[![Swift](https://img.shields.io/badge/swift-3-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![GitHub tag](https://img.shields.io/github/tag/rnine/CryptoHash.svg)](https://github.com/rnine/CryptoHash)
[![License](https://img.shields.io/github/license/mashape/apistatus.svg)](https://github.com/rnine/CryptoHash/blob/develop/LICENSE.md)

Extends `String`, `Data`, and `URL` to easily and efficiently calculate large content checksums. Both sync and async versions are provided for `Data` and `URL`:

#### String

- `checksum(algorithm:)`

#### Data

- `checksum(algorithm:chunkSize:)`
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

#### Synchronous with local URL

```swift
  if let imageURL = Bundle(for: type(of: self)).url(forResource: "image", withExtension: "jpg") {
    // Calculate image file checksum using MD5 digest
    if let checksum = try! imageURL.checksum(algorithm: .md5) {
        // Use computed checksum
    }
  }
```

#### Asynchronous with remote URL

```swift
  let remoteImageURL = URL(string: "https://github.com/rnine/CryptoHash/raw/master/CryptoHashTests/Fixtures/image.jpg")!

  let progress: ProgressHandler = { (bytesProcessed, bytesLeft) in
    print("Bytes processed: \(bytesProcessed), bytes left: \(bytesLeft)"
  }

  try! remoteImageURL.checksum(algorithm: .md5,
                               progress: progress) { (checksum) in
      if let checksum = checksum {
        print("md5 checksum of \(remoteImageURL) is \(checksum)"
      } else {
        print("Unable to obtain checksum.")
      }
  }
```

### Requirements

- Xcode 8 and Swift 3

### License

`Checksum` was written by Ruben Nine ([@sonicbee9](https://twitter.com/sonicbee9)) and is licensed under the [MIT](http://opensource.org/licenses/MIT) license. See [LICENSE.md](LICENSE.md).
