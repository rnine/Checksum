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
    func testReadZero() throws {
        let imageURL = HTTPSFixturesBaseURL.appendingPathComponent("image.jpg")
        let source = try XCTUnwrap(HTTPSource(provider: imageURL))

        XCTAssertNil(source.read(amount: 0))
    }

    func testReadAllAtOnce() throws {
        let imageURL = HTTPSFixturesBaseURL.appendingPathComponent("image.jpg")
        let source = try XCTUnwrap(HTTPSource(provider: imageURL))

        XCTAssertEqual(source.provider, imageURL)
        XCTAssertEqual(source.size, 52226)

        XCTAssertFalse(source.eof())
        let data = try XCTUnwrap(source.read(amount: source.size))
        XCTAssertTrue(source.eof())

        XCTAssertEqual(data.count, source.size)
        XCTAssertEqual(data.checksum(algorithm: .md5), "89808f4076aa649844c0de958bf08fa1")
    }

    func testReadInChunks() throws {
        let imageURL = HTTPSFixturesBaseURL.appendingPathComponent("large-image.jpg")
        let source = try XCTUnwrap(HTTPSource(provider: imageURL))

        XCTAssertEqual(source.provider, imageURL)
        XCTAssertEqual(source.size, 2_928_426)

        var dataChunks = [Data]()

        XCTAssertFalse(source.eof())

        while !source.eof() {
            let data = try XCTUnwrap(source.read(amount: 262_144))
            dataChunks.append(data)
        }

        let data = Data(dataChunks.joined())

        XCTAssertTrue(source.eof())

        XCTAssertEqual(data.count, source.size)
        XCTAssertEqual(data.checksum(algorithm: .md5), "a02b4da2f3769bc6a6fead81c490daad")
    }

    func testSeekAndRead() throws {
        let imageURL = HTTPSFixturesBaseURL.appendingPathComponent("image.jpg")
        let source = try XCTUnwrap(HTTPSource(provider: imageURL))

        XCTAssertTrue(source.seek(position: 1024))
        let data = try XCTUnwrap(source.read(amount: source.size))
        XCTAssertTrue(source.eof())

        XCTAssertEqual(data.count, 52226 - 1024)
    }

    func testSeekAndReadBeyondBounds() throws {
        let imageURL = HTTPSFixturesBaseURL.appendingPathComponent("image.jpg")
        let source = try XCTUnwrap(HTTPSource(provider: imageURL))

        XCTAssertTrue(source.seek(position: 52226))
        XCTAssertNil(source.read(amount: source.size))
        XCTAssertTrue(source.eof())
    }

    func testSeekAndReadWithinBounds() throws {
        let imageURL = HTTPSFixturesBaseURL.appendingPathComponent("image.jpg")
        let source = try XCTUnwrap(HTTPSource(provider: imageURL))

        XCTAssertTrue(source.seek(position: 52225))
        let data = try XCTUnwrap(source.read(amount: source.size))
        XCTAssertTrue(source.eof())

        XCTAssertEqual(data.count, 1)
    }
}
