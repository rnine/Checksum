//
//  DataSourceTests.swift
//  ChecksumTests
//
//  Created by Ruben Nine on 18/09/2019.
//  Copyright © 2019 9Labs. All rights reserved.
//

import XCTest
@testable import Checksum

class DataSourceTests: XCTestCase {
    private let textURL: URL = Bundle(for: FileSourceTests.self).url(forResource: "basic", withExtension: "txt")!
    private let imageURL: URL = Bundle(for: FileSourceTests.self).url(forResource: "image", withExtension: "jpg")!

    func testTextChecksum() throws {
        let textData = try XCTUnwrap(Data(contentsOf: textURL))
        let source = try XCTUnwrap(DataSource(provider: textData))

        XCTAssertEqual(source.provider, textData)
        XCTAssertEqual(source.size, 22)

        XCTAssertFalse(source.eof())
        let data = try XCTUnwrap(source.read(amount: source.size))
        XCTAssertEqual(data.count, 22)
        XCTAssertTrue(source.eof())

        XCTAssertTrue(source.seek(position: 11))
        XCTAssertFalse(source.eof())

        let data2 = try XCTUnwrap(source.read(amount: source.size))
        XCTAssertEqual(data2.count, 11)
        XCTAssertTrue(source.eof())

        XCTAssertEqual(data.subdata(in: (11..<22)), data2)

        XCTAssertEqual(data.count, source.size)
        XCTAssertEqual(data.checksum(algorithm: .md5), "59769e54d93d7d5975fdefa567ac745b")
    }

    func testImageChecksum() throws {
        let imageData = try XCTUnwrap(Data(contentsOf: imageURL))
        let source = try XCTUnwrap(DataSource(provider: imageData))

        XCTAssertEqual(source.provider, imageData)
        XCTAssertEqual(source.size, 52226)

        XCTAssertFalse(source.eof())
        let data = try XCTUnwrap(source.read(amount: source.size))
        XCTAssertTrue(source.eof())

        XCTAssertEqual(data.count, source.size)
        XCTAssertEqual(data.checksum(algorithm: .md5), "89808f4076aa649844c0de958bf08fa1")
    }

    func testSeekAndRead() throws {
        let textData = try! Data(contentsOf: textURL)
        let source = try XCTUnwrap(DataSource(provider: textData))

        XCTAssertEqual(source.provider, textData)
        XCTAssertEqual(source.size, 22)

        // Read whole file
        XCTAssertFalse(source.eof())
        let data = try XCTUnwrap(source.read(amount: source.size))
        XCTAssertEqual(data.count, 22)
        XCTAssertTrue(source.eof())

        // Seek to 11
        XCTAssertTrue(source.seek(position: 11))
        XCTAssertFalse(source.eof())

        // Read last half
        let data2 = try XCTUnwrap(source.read(amount: source.size))
        XCTAssertEqual(data2.count, 11)
        XCTAssertEqual(data.subdata(in: (11..<22)), data2)
        XCTAssertTrue(source.eof())

        // Seek to 0
        XCTAssertTrue(source.seek(position: 0))

        // Read first half
        let data3 = try XCTUnwrap(source.read(amount: 11))
        XCTAssertEqual(data3.count, 11)
        XCTAssertEqual(data.subdata(in: (0..<11)), data3)
        XCTAssertFalse(source.eof())

        // Seek to 0
        XCTAssertTrue(source.seek(position: 0))

        // Seek within bounds
        XCTAssertTrue(source.seek(position: 21))
        XCTAssertEqual(source.tell(), 21)

        // Seek to 0
        XCTAssertTrue(source.seek(position: 0))

        // Seek beyond bounds
        XCTAssertFalse(source.seek(position: 22))
        XCTAssertEqual(source.tell(), 0)
    }
}
