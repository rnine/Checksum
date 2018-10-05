//
//  HTTPSourceTests.swift
//  ChecksumTests
//
//  Created by Ruben Nine on 10/5/18.
//  Copyright © 2018 9Labs. All rights reserved.
//

import XCTest
@testable import Checksum

class HTTPSourceTests: XCTestCase {

    func testImageChecksum() {
        let imageURL = URL(string: "https://github.com/rnine/Checksum/raw/master/ChecksumTests/Fixtures/image.jpg")!

        let source: HTTPSource! = HTTPSource(url: imageURL)

        XCTAssertEqual(source.url, imageURL)
        XCTAssertEqual(source.size, 52226)
        XCTAssertEqual(source.seekable, true)

        XCTAssertFalse(source.eof())
        let data = source.read(amount: source.size)
        XCTAssertNotNil(data)
        XCTAssertTrue(source.eof())

        XCTAssertEqual(data!.count, source.size)

        XCTAssertEqual(data!.checksum(algorithm: .md5), "89808f4076aa649844c0de958bf08fa1")
    }
}
