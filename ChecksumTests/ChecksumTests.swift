//
//  ChecksumTests.swift
//  ChecksumTests
//
//  Created by Ruben Nine on 11/11/2016.
//  Copyright © 2016 9Labs. All rights reserved.
//

import XCTest
@testable import Checksum

class ChecksumTests: XCTestCase {
    
    let basicString = "This is a simple string"

    private let basicTextChecksums: [DigestAlgorithm: String] = [
        .md5: "59769e54d93d7d5975fdefa567ac745b",
        .sha1: "d0bb2056b5bdd929097dc036746cb3089613cc6e",
        .sha224: "6558b657abc32403dd96b0b3d4502ec0fa98d2c1b8f2c0cefbd189e7",
        .sha256: "4cddaf6ca197d07fbbe8db92107eb7a1a5657e93e19418bdd31b68496ca9481a",
        .sha384: "8259f5d9e704c952fc091670bb4ee5cc2d24c3e5358309983a4869db3db7dca640b93be99c739a68b31fc7c5ff02aaa9",
        .sha512: "6ef4ec474ca67752758c654873e8dd5775dbf108d7a70427f0729358e72a999ddb414e24335424fe1f2ed4ab8f541cec935b6504007ef31862017461fc8f660f"
    ]

    private let imageChecksums: [DigestAlgorithm: String] = [
        .md5: "89808f4076aa649844c0de958bf08fa1",
        .sha1: "59cb91199a8b1302b5ceb47a017d39168b05eeaf",
        .sha224: "b81fc73418840c66125988d11a36e89b51e72a50d29ab161a7e0e123",
        .sha256: "a8ecd692db46c8cc285d8228eec8abe384fca2f599bb795942c80ca4015e660e",
        .sha384: "d01bb40389002a9456e0a92f5888c060cdae526564a7973b686f5e97ab6643d7f91da8453150b228b7fac2c950886d91",
        .sha512: "8468be6e8f6b1e3d60504d2dded8352192a161f494250b93ab55afc8e9f7f7fcb51badb1efd0037230ee81dbddbbcd2c19338437faefadffc104f9b3d77036d7"
    ]


    func testMD5() {
        let algorithm: DigestAlgorithm = .md5
        let data = basicString.data(using: .utf8)!
        let expectedHash = "0f13e02ea41fb763b0ad09daa72a4b6e"

        if let checksum = basicString.checksum(algorithm: algorithm) {
            XCTAssertEqual(checksum, expectedHash)
        }

        if let checksum = data.checksum(algorithm: algorithm) {
            XCTAssertEqual(checksum, expectedHash)
        }
    }

    func testAsyncTextURL() {
        var expectations: [XCTestExpectation] = []
        let textURL = Bundle(for: type(of: self)).url(forResource: "basic", withExtension: "txt")!

        for algorithm in basicTextChecksums.keys {
            let expect = expectation(description: "completion")
            expectations.append(expect)

            textURL.checksum(algorithm: algorithm, progress: nil) { (checksum) in
                XCTAssertEqual(checksum, self.basicTextChecksums[algorithm])
                expect.fulfill()
            }
        }

        waitForExpectations(timeout: 20)
    }

    func testAsyncImageURL() {
        var expectations: [XCTestExpectation] = []
        let imageURL = Bundle(for: type(of: self)).url(forResource: "image", withExtension: "jpg")!

        for algorithm in imageChecksums.keys {
            let expect = expectation(description: "completion")
            expectations.append(expect)

            imageURL.checksum(algorithm: algorithm, progress: nil) { (checksum) in
                XCTAssertEqual(checksum, self.imageChecksums[algorithm])
                expect.fulfill()
            }
        }

        waitForExpectations(timeout: 20)
    }

    func testMultipleAsyncLocalURLs() {
        var expectations: [XCTestExpectation] = []

        let textURL = Bundle(for: type(of: self)).url(forResource: "basic", withExtension: "txt")!
        let imageURL = Bundle(for: type(of: self)).url(forResource: "image", withExtension: "jpg")!
        let textRemoteURL = URL(string: "https://github.com/rnine/Checksum/raw/master/ChecksumTests/Fixtures/basic.txt")!
        let imageRemoteURL = URL(string: "https://github.com/rnine/Checksum/raw/master/ChecksumTests/Fixtures/image.jpg")!
        let invalidURL = URL(string: "file://invalidpath")!
        let invalidProtocolURL = URL(string: "invalidProtocol://invalidpath")!
        let unexistingRemoteURL = URL(string: "https://github.com/rnine/Checksum/raw/master/ChecksumTests/Fixtures/unexistingFile.txt")!
        let urls = [textURL, imageURL, invalidProtocolURL, textRemoteURL, imageRemoteURL, invalidURL, unexistingRemoteURL]

        let expect = expectation(description: "completion")
        expectations.append(expect)

        let progress: ProgressHandler = { bytesProcessed, totalBytes in
            print("bytesProcessed = \(bytesProcessed), totalBytes = \(totalBytes)")
        }

        urls.checksum(algorithm: .md5, progress: progress) { (checksums) in
            XCTAssertEqual(checksums[0], self.basicTextChecksums[.md5])
            XCTAssertEqual(checksums[1], self.imageChecksums[.md5])
            XCTAssertEqual(checksums[2], nil)
            XCTAssertEqual(checksums[3], self.basicTextChecksums[.md5])
            XCTAssertEqual(checksums[4], self.imageChecksums[.md5])
            XCTAssertEqual(checksums[5], nil)
            XCTAssertEqual(checksums[6], nil)

            expect.fulfill()
        }

        waitForExpectations(timeout: 20)
    }


    func testAsyncRemoteTextURL() {
        var expectations: [XCTestExpectation] = []
        let textURL = URL(string: "https://github.com/rnine/Checksum/raw/master/ChecksumTests/Fixtures/basic.txt")!

        for algorithm in basicTextChecksums.keys {
            let expect = expectation(description: "completion")
            expectations.append(expect)

            textURL.checksum(algorithm: algorithm, progress: nil) { (checksum) in
                XCTAssertEqual(checksum, self.basicTextChecksums[algorithm])
                expect.fulfill()
            }
        }

        waitForExpectations(timeout: 20)
    }

    func testAsyncRemoteImageURL() {
        var expectations: [XCTestExpectation] = []
        let imageURL = URL(string: "https://github.com/rnine/Checksum/raw/master/ChecksumTests/Fixtures/image.jpg")!

        for algorithm in imageChecksums.keys {
            let expect = expectation(description: "completion")
            expectations.append(expect)

            imageURL.checksum(algorithm: algorithm, progress: nil) { (checksum) in
                XCTAssertEqual(checksum, self.imageChecksums[algorithm])
                expect.fulfill()
            }
        }

        waitForExpectations(timeout: 20)
    }
}
