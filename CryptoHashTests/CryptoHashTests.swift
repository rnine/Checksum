//
//  CryptoHashTests.swift
//  CryptoHashTests
//
//  Created by Ruben Nine on 11/11/2016.
//  Copyright © 2016 9Labs. All rights reserved.
//

import XCTest
@testable import CryptoHash

class CryptoHashTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    let basicString = "This is a simple string"
    
    func testMD5() {
        let algorithm: DigestAlgorithm = .md5
        let data = basicString.data(using: .utf8)!
        let expectedHash = "0f13e02ea41fb763b0ad09daa72a4b6e"

        if let checksum = try! basicString.checksum(algorithm: algorithm) {
            XCTAssertEqual(checksum, expectedHash)
        }

        if let checksum = try! data.checksum(algorithm: algorithm) {
            XCTAssertEqual(checksum, expectedHash)
        }
    }

    func testMD5URL() {
        let textURL = Bundle(for: type(of: self)).url(forResource: "basic", withExtension: "txt")!
        let imageURL = Bundle(for: type(of: self)).url(forResource: "image", withExtension: "jpg")!

        if let checksum = try! textURL.checksum(algorithm: .md5) {
            XCTAssertEqual(checksum, "59769e54d93d7d5975fdefa567ac745b")
        }

        if let checksum = try! imageURL.checksum(algorithm: .md5) {
            XCTAssertEqual(checksum, "89808f4076aa649844c0de958bf08fa1")
        }
    }

    func testSHA1() {
        let algorithm: DigestAlgorithm = .sha1
        let data = basicString.data(using: .utf8)!
        let expectedHash = "3d745cc2fb07a4e3cb3bc0d5666ad1e358e15101"

        if let checksum = try! basicString.checksum(algorithm: algorithm) {
            XCTAssertEqual(checksum, expectedHash)
        }

        if let checksum = try! data.checksum(algorithm: algorithm) {
            XCTAssertEqual(checksum, expectedHash)
        }
    }

    func testSHA1URL() {
        let textURL = Bundle(for: type(of: self)).url(forResource: "basic", withExtension: "txt")!
        let imageURL = Bundle(for: type(of: self)).url(forResource: "image", withExtension: "jpg")!

        if let checksum = try! textURL.checksum(algorithm: .sha1) {
            XCTAssertEqual(checksum, "d0bb2056b5bdd929097dc036746cb3089613cc6e")
        }

        if let checksum = try! imageURL.checksum(algorithm: .sha1) {
            XCTAssertEqual(checksum, "59cb91199a8b1302b5ceb47a017d39168b05eeaf")
        }
    }

    func testSHA224() {
        let algorithm: DigestAlgorithm = .sha224
        let data = basicString.data(using: .utf8)!

        if let checksum = try! basicString.checksum(algorithm: algorithm) {
            XCTAssertEqual(checksum, "e04620110086023743868a5c4be028c7f733de45a2c58134623e016f")
        }

        if let checksum = try! data.checksum(algorithm: algorithm) {
            XCTAssertEqual(checksum, "e04620110086023743868a5c4be028c7f733de45a2c58134623e016f")
        }
    }

    func testSHA224URL() {
        let textURL = Bundle(for: type(of: self)).url(forResource: "basic", withExtension: "txt")!
        let imageURL = Bundle(for: type(of: self)).url(forResource: "image", withExtension: "jpg")!

        if let checksum = try! textURL.checksum(algorithm: .sha224) {
            XCTAssertEqual(checksum, "6558b657abc32403dd96b0b3d4502ec0fa98d2c1b8f2c0cefbd189e7")
        }

        if let checksum = try! imageURL.checksum(algorithm: .sha224) {
            XCTAssertEqual(checksum, "b81fc73418840c66125988d11a36e89b51e72a50d29ab161a7e0e123")
        }
    }

    func testSHA256() {
        let algorithm: DigestAlgorithm = .sha256
        let data = basicString.data(using: .utf8)!
        let expectedHash = "99eb09d996baedd3d1603c890058e308552456bc9d11712b149fe2d5772532cf"

        if let checksum = try! basicString.checksum(algorithm: algorithm) {
            XCTAssertEqual(checksum, expectedHash)
        }

        if let checksum = try! data.checksum(algorithm: algorithm) {
            XCTAssertEqual(checksum, expectedHash)
        }
    }

    func testSHA256URL() {
        let textURL = Bundle(for: type(of: self)).url(forResource: "basic", withExtension: "txt")!
        let imageURL = Bundle(for: type(of: self)).url(forResource: "image", withExtension: "jpg")!

        if let checksum = try! textURL.checksum(algorithm: .sha256) {
            XCTAssertEqual(checksum, "4cddaf6ca197d07fbbe8db92107eb7a1a5657e93e19418bdd31b68496ca9481a")
        }

        if let checksum = try! imageURL.checksum(algorithm: .sha256) {
            XCTAssertEqual(checksum, "a8ecd692db46c8cc285d8228eec8abe384fca2f599bb795942c80ca4015e660e")
        }
    }

    func testSHA384() {
        let algorithm: DigestAlgorithm = .sha384
        let data = basicString.data(using: .utf8)!
        let expectedHash = "08d6af9d00df916f3e33743588c00e00f25433392bda805cfcb3582fbc3f659de5a374d41658602ae27670ba9320da58"

        if let checksum = try! basicString.checksum(algorithm: algorithm) {
            XCTAssertEqual(checksum, expectedHash)
        }

        if let checksum = try! data.checksum(algorithm: algorithm) {
            XCTAssertEqual(checksum, expectedHash)
        }
    }

    func testSHA384URL() {
        let textURL = Bundle(for: type(of: self)).url(forResource: "basic", withExtension: "txt")!
        let imageURL = Bundle(for: type(of: self)).url(forResource: "image", withExtension: "jpg")!

        if let checksum = try! textURL.checksum(algorithm: .sha384) {
            XCTAssertEqual(checksum, "8259f5d9e704c952fc091670bb4ee5cc2d24c3e5358309983a4869db3db7dca640b93be99c739a68b31fc7c5ff02aaa9")
        }

        if let checksum = try! imageURL.checksum(algorithm: .sha384) {
            XCTAssertEqual(checksum, "d01bb40389002a9456e0a92f5888c060cdae526564a7973b686f5e97ab6643d7f91da8453150b228b7fac2c950886d91")
        }
    }

    func testSHA512() {
        let algorithm: DigestAlgorithm = .sha512
        let data = basicString.data(using: .utf8)!
        let expectedHash = "8b14d001deabe20a91b6e22cb452f27a02840f2e451ce566c54ed3fec211f06a6fb40c0002f0d23279cf58cccde909ab1aa7592e1ab5e0f2bce10d6be36f9ed1"

        if let checksum = try! basicString.checksum(algorithm: algorithm) {
            XCTAssertEqual(checksum, expectedHash)
        }

        if let checksum = try! data.checksum(algorithm: algorithm) {
            XCTAssertEqual(checksum, expectedHash)
        }
    }

    func testSHA512URL() {
        let textURL = Bundle(for: type(of: self)).url(forResource: "basic", withExtension: "txt")!
        let imageURL = Bundle(for: type(of: self)).url(forResource: "image", withExtension: "jpg")!

        if let checksum = try! textURL.checksum(algorithm: .sha512) {
            XCTAssertEqual(checksum, "6ef4ec474ca67752758c654873e8dd5775dbf108d7a70427f0729358e72a999ddb414e24335424fe1f2ed4ab8f541cec935b6504007ef31862017461fc8f660f")
        }

        if let checksum = try! imageURL.checksum(algorithm: .sha512) {
            XCTAssertEqual(checksum, "8468be6e8f6b1e3d60504d2dded8352192a161f494250b93ab55afc8e9f7f7fcb51badb1efd0037230ee81dbddbbcd2c19338437faefadffc104f9b3d77036d7")
        }
    }

}
