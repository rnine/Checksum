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
    // MARK: - Configuration

    private let waitTimeout: TimeInterval = 20

    // MARK: - Fixtures

    private let simpleString = "This is a simple string"

    private lazy var localTextURL: URL = {
        Bundle(for: type(of: self)).url(forResource: "basic", withExtension: "txt")!
    }()

    private lazy var localImageURL: URL = {
        Bundle(for: type(of: self)).url(forResource: "image", withExtension: "jpg")!
    }()

    private let remoteTextURL = URL(string: "https://github.com/rnine/Checksum/raw/develop/Tests/Fixtures/basic.txt")!
    private let remoteImageURL = URL(string: "https://github.com/rnine/Checksum/raw/develop/Tests/Fixtures/image.jpg")!

    private let unhandledSchemeURL = URL(string: "gopher://somewhere")!
    private let unreachableLocalURL = URL(string: "file://SOME/RANDOM/UNEXISTING/URL/10192371")!
    private let unreachableRemoteURL = URL(string: "https://9labs.io/SOME/RANDOM/UNEXISTING/URL/10192371")!

    private let simpleStringMD5Checksum = "0f13e02ea41fb763b0ad09daa72a4b6e"

    private let textChecksums: [DigestAlgorithm: String] = [
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

    // MARK: - Single Checksumable Tests

    func testMD5String() {
        // Sync
        XCTAssertEqual(simpleString.checksum(algorithm: .md5), simpleStringMD5Checksum)
        // Async
        AssertSuccessfulChecksum(using: simpleString, algorithm: .md5, expected: simpleStringMD5Checksum)
    }

    func testMD5Data() {
        let simpleStringData = simpleString.data(using: .utf8)!
        // Sync
        XCTAssertEqual(simpleStringData.checksum(algorithm: .md5), simpleStringMD5Checksum)
        // Async
        AssertSuccessfulChecksum(using: simpleStringData, algorithm: .md5, expected: simpleStringMD5Checksum)
    }

    func testLocalTextURL() {
        AssertSuccessfulChecksum(using: localTextURL, algorithm: .md5, expected: textChecksums[.md5]!)
        AssertSuccessfulChecksum(using: localTextURL, algorithm: .sha1, expected: textChecksums[.sha1]!)
        AssertSuccessfulChecksum(using: localTextURL, algorithm: .sha224, expected: textChecksums[.sha224]!)
        AssertSuccessfulChecksum(using: localTextURL, algorithm: .sha256, expected: textChecksums[.sha256]!)
        AssertSuccessfulChecksum(using: localTextURL, algorithm: .sha384, expected: textChecksums[.sha384]!)
        AssertSuccessfulChecksum(using: localTextURL, algorithm: .sha512, expected: textChecksums[.sha512]!)
    }

    func testLocalImageURL() {
        AssertSuccessfulChecksum(using: localImageURL, algorithm: .md5, expected: imageChecksums[.md5]!)
        AssertSuccessfulChecksum(using: localImageURL, algorithm: .sha1, expected: imageChecksums[.sha1]!)
        AssertSuccessfulChecksum(using: localImageURL, algorithm: .sha224, expected: imageChecksums[.sha224]!)
        AssertSuccessfulChecksum(using: localImageURL, algorithm: .sha256, expected: imageChecksums[.sha256]!)
        AssertSuccessfulChecksum(using: localImageURL, algorithm: .sha384, expected: imageChecksums[.sha384]!)
        AssertSuccessfulChecksum(using: localImageURL, algorithm: .sha512, expected: imageChecksums[.sha512]!)
    }

    func testRemoteTextURL() {
        AssertSuccessfulChecksum(using: remoteTextURL, algorithm: .md5, expected: textChecksums[.md5]!)
        AssertSuccessfulChecksum(using: remoteTextURL, algorithm: .sha1, expected: textChecksums[.sha1]!)
        AssertSuccessfulChecksum(using: remoteTextURL, algorithm: .sha224, expected: textChecksums[.sha224]!)
        AssertSuccessfulChecksum(using: remoteTextURL, algorithm: .sha256, expected: textChecksums[.sha256]!)
        AssertSuccessfulChecksum(using: remoteTextURL, algorithm: .sha384, expected: textChecksums[.sha384]!)
        AssertSuccessfulChecksum(using: remoteTextURL, algorithm: .sha512, expected: textChecksums[.sha512]!)
    }

    func testRemoteImageURL() {
        AssertSuccessfulChecksum(using: remoteImageURL, algorithm: .md5, expected: imageChecksums[.md5]!)
        AssertSuccessfulChecksum(using: remoteImageURL, algorithm: .sha1, expected: imageChecksums[.sha1]!)
        AssertSuccessfulChecksum(using: remoteImageURL, algorithm: .sha224, expected: imageChecksums[.sha224]!)
        AssertSuccessfulChecksum(using: remoteImageURL, algorithm: .sha256, expected: imageChecksums[.sha256]!)
        AssertSuccessfulChecksum(using: remoteImageURL, algorithm: .sha384, expected: imageChecksums[.sha384]!)
        AssertSuccessfulChecksum(using: remoteImageURL, algorithm: .sha512, expected: imageChecksums[.sha512]!)
    }

    func testUnhandledURLScheme() {
        AssertFailedChecksum(using: unhandledSchemeURL, algorithm: .md5, expectedError: .unusableSource)
    }

    func testUnreachableLocalURL() {
        AssertFailedChecksum(using: unreachableLocalURL, algorithm: .md5, expectedError: .unusableSource)
    }

    func testUnreachableRemoteURL() {
        AssertFailedChecksum(using: unreachableRemoteURL, algorithm: .md5, expectedError: .unusableSource)
    }

    // MARK: - Multiple Checksumable Tests

    func testMultipleURLs() {
        let expect = expectation(description: "completion")

        let expectedResults: [URL: String?] = [
            localTextURL: textChecksums[.md5],
            localImageURL: imageChecksums[.md5],
            unhandledSchemeURL: nil,
            remoteTextURL: textChecksums[.md5],
            remoteImageURL: imageChecksums[.md5],
            unreachableLocalURL: nil,
            unreachableRemoteURL: nil
        ]

        Array(expectedResults.keys).checksum(algorithm: .md5) { result in
            switch result {
            case .success(let results):
                XCTAssertEqual(results.count, expectedResults.count)

                for result in results {
                    guard let url = result.checksumable as? URL else {
                        XCTFail("Expected checksumable to be of type URL.")
                        return
                    }

                    XCTAssertEqual(expectedResults[url], result.checksum, "using \(url)")
                }
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            }

            expect.fulfill()
        }

        waitForExpectations(timeout: waitTimeout)
    }

    // MARK: - Private Functions

    private func AssertSuccessfulChecksum(using checksumable: Checksumable,
                                          algorithm: DigestAlgorithm,
                                          expected: String,
                                          file: StaticString = #file,
                                          line: UInt = #line) {
        let expect = expectation(description: "completion")

        checksumable.checksum(algorithm: algorithm, chunkSize: .normal, queue: .main, progress: nil) { result in
            let returned = try? result.get()
            XCTAssertEqual(returned, expected, "using \(checksumable)", file: file, line: line)

            expect.fulfill()
        }

        waitForExpectations(timeout: waitTimeout)
    }

    private func AssertFailedChecksum(using checksumable: Checksumable,
                                      algorithm: DigestAlgorithm,
                                      expectedError: ChecksumError,
                                      file: StaticString = #file,
                                      line: UInt = #line) {
        let expect = expectation(description: "completion")

        checksumable.checksum(algorithm: algorithm, chunkSize: .normal, queue: .main, progress: nil) { result in
            switch result {
            case .success(_):
                XCTFail("Should not succeed.", file: file, line: line)
            case .failure(let error):
                XCTAssertEqual(error, expectedError, file: file, line: line)
            }

            expect.fulfill()
        }

        waitForExpectations(timeout: waitTimeout)
    }
}
