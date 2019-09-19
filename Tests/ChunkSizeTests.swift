//
//  ChunkSizeTests.swift
//  Checksum
//
//  Created by Ruben Nine on 19/09/2019.
//  Copyright © 2019 9Labs. All rights reserved.
//

import XCTest
@testable import Checksum

class ChunkSizeTests: XCTestCase {

    func testBytes() {
        XCTAssertEqual(Chunksize.tiny.bytes, 16 * 1024)
        XCTAssertEqual(Chunksize.small.bytes, 64 * 1024)
        XCTAssertEqual(Chunksize.normal.bytes, 256 * 1024)
        XCTAssertEqual(Chunksize.large.bytes, 1024 * 1024)
        XCTAssertEqual(Chunksize.huge.bytes, 4096 * 1024)
        XCTAssertEqual(Chunksize.custom(size: 32_768).bytes, 32_768)
    }
}
