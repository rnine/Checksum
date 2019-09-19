//
//  URLTests.swift
//  ChecksumTests
//
//  Created by Ruben Nine on 19/09/2019.
//  Copyright © 2019 9Labs. All rights reserved.
//

import XCTest
@testable import Checksum

class URLTests: XCTestCase {

    func testHTTPSource() {
        let url = HTTPFixturesBaseURL.appendingPathComponent("image.jpg")

        XCTAssert(url.source is HTTPSource, String(describing: url.source))
    }

    func testHTTPSSource() {
        let url = HTTPSFixturesBaseURL.appendingPathComponent("image.jpg")

        XCTAssert(url.source is HTTPSource, String(describing: url.source))
    }

    func testFileSource() {
        let url = LocalFixturesBaseURL.appendingPathComponent("basic.txt")

        XCTAssert(url.source is FileSource, String(describing: url.source))
    }

    func testUnhandledSource() {
        let url = URL(string: "gopher://12391")!

        XCTAssertNil(url.source)
    }
}
