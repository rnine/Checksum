//
//  HTTPSource.swift
//  Checksum
//
//  Created by Ruben Nine on 10/5/18.
//  Copyright © 2018 9Labs. All rights reserved.
//

import Foundation

class HTTPSource: InstantiableSource {
    typealias Provider = URL

    // MARK: - Public Properties

    let provider: URL
    private(set) var size: Int = 0

    // MARK: - Private Properties

    private var urlSession = URLSession(configuration: .ephemeral)
    private var position: Int = 0
    private let processQueue = DispatchQueue(label: "io.9labs.Checksum.http-source-process")
    private let semaphore = DispatchSemaphore(value: 0)
    private let requestTimeOut: TimeInterval = 5.0

    // MARK: - Lifecycle

    required init?(provider url: URL) {
        var success = false

        self.provider = url

        processQueue.sync {
            var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: requestTimeOut)

            request.httpShouldUsePipelining = true
            request.httpMethod = "HEAD"

            let task = urlSession.dataTask(with: request) { _, response, error in
                if error == nil, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    self.size = Int(httpResponse.expectedContentLength)
                    success = true
                }

                self.semaphore.signal()
            }

            task.resume()
        }

        _ = semaphore.wait(timeout: .distantFuture)

        guard success == true else { return nil }
    }

    deinit {
        close()
    }

    // MARK: - Public functions

    func seek(position: Int) -> Bool {
        self.position = position

        return true
    }

    func tell() -> Int {
        return position
    }

    func eof() -> Bool {
        return tell() == size
    }

    func read(amount: Int) -> Data? {
        if size != -1, position >= size {
            return nil
        }

        var readData: Data?

        processQueue.sync {
            autoreleasepool {
                var urlRequest = URLRequest(url: provider, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: requestTimeOut)

                urlRequest.httpShouldUsePipelining = true

                if size == -1 {
                    // Size is unknown
                    urlRequest.addValue("bytes=\(position)-", forHTTPHeaderField: "Range")
                } else {
                    let bytesToRead = Swift.min(amount, size - position)
                    let range: (Int, Int) = (position, position + bytesToRead - 1)
                    urlRequest.addValue("bytes=\(range.0)-\(range.1)", forHTTPHeaderField: "Range")
                }

                let task = urlSession.dataTask(with: urlRequest) { data, response, _ in
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

        _ = semaphore.wait(timeout: .distantFuture)

        return readData
    }

    func close() {
        urlSession.invalidateAndCancel()
    }
}
