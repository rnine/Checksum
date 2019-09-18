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

    func testImageChecksum() throws {
        let imageURL = URL(string: "https://github.com/rnine/Checksum/raw/master/Tests/Fixtures/image.jpg")!
        let source = try XCTUnwrap(HTTPSource(provider: imageURL))

        XCTAssertEqual(source.provider, imageURL)
        XCTAssertEqual(source.size, 52226)

        XCTAssertFalse(source.eof())
        let data = try XCTUnwrap(source.read(amount: source.size))
        XCTAssertTrue(source.eof())

        XCTAssertEqual(data.count, source.size)
        XCTAssertEqual(data.checksum(algorithm: .md5), "89808f4076aa649844c0de958bf08fa1")
    }
}
