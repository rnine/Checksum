//
//  DataSource.swift
//  ChecksumTests
//
//  Created by Ruben Nine on 14/09/2019.
//  Copyright © 2019 9Labs. All rights reserved.
//

import Foundation

class DataSource: InstantiableSource {
    typealias Provider = Data

    // MARK: - Public Properties

    let provider: Data
    let size: Int

    // MARK: - Private Properties

    private var seekOffset: Int = 0

    // MARK: - Lifecycle

    required init?(provider data: Data) {
        self.provider = data
        self.size = data.count
    }

    // MARK: - Public functions

    func seek(position: Int) -> Bool {
        guard position < size else { return false }

        self.seekOffset = position

        return true
    }

    func tell() -> Int {
        return seekOffset
    }

    func eof() -> Bool {
        return tell() == size
    }

    func read(amount: Int) -> Data? {
        let start = Int(truncatingIfNeeded: seekOffset)
        let end: Int = min(start.advanced(by: amount), provider.count)
        let dataChunk = provider.subdata(in: start ..< end)

        seekOffset += dataChunk.count

        return dataChunk
    }

    func close() {
        // NO-OP
    }
}
