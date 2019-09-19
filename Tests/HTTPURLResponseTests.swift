//
//  HTTPURLResponseTests.swift
//  Checksum
//
//  Created by Ruben Nine on 19/09/2019.
//  Copyright © 2019 9Labs. All rights reserved.
//

import XCTest
@testable import Checksum

class HTTPURLResponseTests: XCTestCase {

    func testValidContentRange() throws {
        let response = try XCTUnwrap(HTTPURLResponse(url: URL(string: "https://foo")!,
                                       statusCode: 206,
                                       httpVersion: nil,
                                       headerFields: ["Content-Range": "bytes 0-1023/1024"]))

        let contentRange = try XCTUnwrap(response.contentRange)

        XCTAssertEqual(contentRange.range, (0...1023))
        XCTAssertEqual(contentRange.size, 1024)
    }

    func testInvalidContentRange() throws {
        let response = try XCTUnwrap(HTTPURLResponse(url: URL(string: "https://foo")!,
                                       statusCode: 206,
                                       httpVersion: nil,
                                       headerFields: ["Content-Range": "bytes 0-1023"]))

        XCTAssertNil(response.contentRange)
    }

    func testInvalidContentRange2() throws {
        let response = try XCTUnwrap(HTTPURLResponse(url: URL(string: "https://foo")!,
                                       statusCode: 206,
                                       httpVersion: nil,
                                       headerFields: ["Content-Range": "0-1023"]))

        XCTAssertNil(response.contentRange)
    }

    func testInvalidContentRange3() throws {
        let response = try XCTUnwrap(HTTPURLResponse(url: URL(string: "https://foo")!,
                                       statusCode: 206,
                                       httpVersion: nil,
                                       headerFields: ["Content-Range": "bytes abc-1024/1024"]))

        XCTAssertNil(response.contentRange)
    }

    func testInvalidContentRange4() throws {
        let response = try XCTUnwrap(HTTPURLResponse(url: URL(string: "https://foo")!,
                                       statusCode: 206,
                                       httpVersion: nil,
                                       headerFields: ["Content-Range": "bytes 0-abc/1024"]))

        XCTAssertNil(response.contentRange)
    }
}
