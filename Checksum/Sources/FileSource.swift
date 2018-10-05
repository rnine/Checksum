//
//  FileSource.swift
//  Checksum
//
//  Created by Ruben Nine on 10/5/18.
//  Copyright © 2018 9Labs. All rights reserved.
//

import Foundation

public class FileSource: Source {


    // MARK: - Public Properties

    let url: URL
    let size: Int

    static var schemes: [String] {
        return ["file"]
    }

    var seekable: Bool {
        return true
    }


    // MARK: - Private Properties

    private var fd: UnsafeMutablePointer<FILE>!


    // MARK: - Lifecycle

    required init?(url: URL) {
        self.url = url

        if let fd = fopen(url.path, "r") {
            self.fd = fd
        } else {
            return nil
        }

        let curpos = ftello(fd)
        fseeko(fd, 0, SEEK_END)
        self.size = Int(ftello(fd))
        fseeko(fd, curpos, SEEK_SET)
    }

    deinit {
        close()
    }


    // MARK: - Public functions

    func seek(position: Int, whence: Int) -> Bool {
        return (fseeko(fd, off_t(position), Int32(whence)) == 0)
    }

    func tell() -> Int {
        return Int(ftello(fd))
    }

    func eof() -> Bool {
        return tell() == size
    }

    func read(amount: Int) -> Data? {
        var data = Data(repeating: 0, count: amount)
        var actualBytesRead: Int = 0

        data.withUnsafeMutableBytes { (u8Ptr: UnsafeMutablePointer<UInt8>) in
            let uMutablePtr = UnsafeMutablePointer(mutating: u8Ptr)
            actualBytesRead = fread(uMutablePtr, 1, amount, fd)
        }

        data.count = actualBytesRead

        return data
    }

    func close() {
        fclose(fd)
    }
}
