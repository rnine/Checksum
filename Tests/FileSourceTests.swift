//
//  FileSourceTests.swift
//  ChecksumTests
//
//  Created by Ruben Nine on 10/5/18.
//  Copyright © 2018 9Labs. All rights reserved.
//

import XCTest
@testable import Checksum

class FileSourceTests: XCTestCase {
    func testTextChecksum() {
        let textURL = Bundle(for: type(of: self)).url(forResource: "basic", withExtension: "txt")!

        let source: FileSource! = FileSource(provider: textURL)

        XCTAssertEqual(source.provider, textURL)
        XCTAssertEqual(source.size, 22)

        XCTAssertFalse(source.eof())
        let data = source.read(amount: source.size)
        XCTAssertNotNil(data)
        XCTAssertTrue(source.eof())

        XCTAssertEqual(data!.count, source.size)
        XCTAssertEqual(data!.checksum(algorithm: .md5), "59769e54d93d7d5975fdefa567ac745b")
    }

    func testImageChecksum() {
        let imageURL = Bundle(for: type(of: self)).url(forResource: "image", withExtension: "jpg")!

        let source: FileSource! = FileSource(provider: imageURL)

        XCTAssertEqual(source.provider, imageURL)
        XCTAssertEqual(source.size, 52226)

        XCTAssertFalse(source.eof())
        let data = source.read(amount: source.size)
        XCTAssertNotNil(data)
        XCTAssertTrue(source.eof())

        XCTAssertEqual(data!.count, source.size)
        XCTAssertEqual(data!.checksum(algorithm: .md5), "89808f4076aa649844c0de958bf08fa1")
    }
}
