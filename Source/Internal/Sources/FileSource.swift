//
//  FileSource.swift
//  Checksum
//
//  Created by Ruben Nine on 10/5/18.
//  Copyright © 2018 9Labs. All rights reserved.
//

import Foundation

class FileSource: InstantiableSource {
    typealias Provider = URL

    // MARK: - Public Properties

    let provider: URL
    let size: Int

    // MARK: - Private Properties

    private var fd: UnsafeMutablePointer<FILE>!

    // MARK: - Lifecycle

    required init?(provider url: URL) {
        self.provider = url

        if let fd = fopen(url.path, "r") {
            self.fd = fd
        } else {
            return nil
        }

        let curpos = ftello(fd)
        fseeko(fd, 0, SEEK_END)
        size = Int(ftello(fd))
        fseeko(fd, curpos, SEEK_SET)
    }

    deinit {
        close()
    }

    // MARK: - Public functions

    func seek(position: Int) -> Bool {
        guard position < size else { return false }
        
        return (fseeko(fd, off_t(position), SEEK_SET) == 0)
    }

    func tell() -> Int {
        return Int(ftello(fd))
    }

    func eof() -> Bool {
        return tell() == size
    }

    func read(amount: Int) -> Data? {
        var data = Data(count: amount)

        data.count = data.withUnsafeMutableBytes {
            fread($0.baseAddress, 1, amount, fd)
        }

        return data
    }

    func close() {
        fclose(fd)
    }
}
