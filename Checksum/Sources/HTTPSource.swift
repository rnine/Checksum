//
//  HTTPSource.swift
//  Checksum
//
//  Created by Ruben Nine on 10/5/18.
//  Copyright © 2018 9Labs. All rights reserved.
//

import Foundation

class HTTPSource: Source {


    // MARK: - Public Properties

    let url: URL

    private(set) var size: Int = 0

    static var schemes: [String] {
        return ["http", "https"]
    }

    var seekable: Bool {
        return true
    }


    // MARK: - Private Properties

    private var urlSession = URLSession(configuration: .ephemeral)
    private var position: Int = 0
    private let lockQueue = DispatchQueue(label: "io.9labs.Checksum.http-source-lock")
    private let semaphore = DispatchSemaphore(value: 0)
    private let requestTimeOut: TimeInterval = 5.0


    // MARK: - Lifecycle

    required init?(url: URL) {
        var success = false

        self.url = url

        lockQueue.sync {
            var request = URLRequest(url: self.url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: requestTimeOut)

            request.httpMethod = "HEAD"

            let task = urlSession.dataTask(with: request) { (data, response, error) in
                if error == nil, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    self.size = Int(httpResponse.expectedContentLength)
                    success = true
                }

                self.semaphore.signal()
            }

            task.resume()
        }

        let _ = semaphore.wait(timeout: .distantFuture)

        guard success == true else { return nil }
    }

    deinit {
        close()
    }


    // MARK: - Public functions

    func seek(position: Int, whence: Int) -> Bool {
        switch Int32(whence) {
        case SEEK_SET:
            self.position = position
        case SEEK_CUR:
            self.position += position
        case SEEK_END:
            if size != -1 {
                self.position = size + position
            }
        default:
            break
        }

        return true
    }

    func tell() -> Int {
        return position
    }

    func eof() -> Bool {
        return tell() == size
    }

    func read(amount: Int) -> Data? {
        if size != -1 && position >= size {
            return nil
        }

        var readData: Data? = nil

        lockQueue.sync {
            autoreleasepool {
                var urlRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: requestTimeOut)

                if size == -1 {
                    // Size is unknown
                    urlRequest.addValue("bytes=\(position)-", forHTTPHeaderField: "Range")
                } else {
                    let bytesToRead = Swift.min(amount, size - position)
                    let range: (Int, Int) = (position, position + bytesToRead - 1)
                    urlRequest.addValue("bytes=\(range.0)-\(range.1)", forHTTPHeaderField: "Range")
                }

                let task = urlSession.dataTask(with: urlRequest) { (data, response, error) in
                    if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 206, let data = data {
                        if self.size == -1 {
                            // Use estimated size for now
                            self.size = Int(httpResponse.expectedContentLength)
                        }

                        readData = data
                        self.position += data.count

                        if data.count < amount {
                            // EOF reached, adjust size.
                            self.size = self.position
                        }
                    }

                    self.semaphore.signal()
                }

                task.resume()
            }
        }

        let _ = semaphore.wait(timeout: .distantFuture)

        return readData
    }

    func close() {
        urlSession.invalidateAndCancel()
    }
}
