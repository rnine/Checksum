//
//  DataTests.swift
//  ChecksumTests
//
//  Created by Ruben Nine on 19/09/2019.
//  Copyright © 2019 9Labs. All rights reserved.
//

import XCTest
@testable import Checksum

class DataTests: XCTestCase {

    func testDataSource() {
        let data = Data()

        XCTAssert(data.source is DataSource, String(describing: data.source))
    }
}
