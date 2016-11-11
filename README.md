# CryptoHash

[![Version](http://cocoapod-badges.herokuapp.com/v/AMCoreAudio/badge.png)](http://cocoadocs.org/docsets/AMCoreAudio)
[![Platform](http://cocoapod-badges.herokuapp.com/p/AMCoreAudio/badge.png)](http://cocoadocs.org/docsets/AMCoreAudio)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![GitHub tag](https://img.shields.io/github/tag/rnine/AMCoreAudio.svg)](https://github.com/rnine/AMCoreAudio)
[![License](https://img.shields.io/github/license/mashape/apistatus.svg)](https://github.com/rnine/AMCoreAudio/blob/develop/LICENSE.md)

Extends `String`, `Data`, and `URL` to easily and efficiently calculate large content checksums.

Supported digests:

- MD5
- SHA1
- SHA224
- SHA256
- SHA384
- SHA512


Example:

```swift
  let imageURL = Bundle(for: type(of: self)).url(forResource: "image", withExtension: "jpg")!

  // Calculate image file checksum using MD5 digest
  if let computedChecksum = try! imageURL.cryptoHash(algorithm: .md5) {
      // Use computed checksum
  }
```
