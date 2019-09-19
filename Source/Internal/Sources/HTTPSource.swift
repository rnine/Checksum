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

    private(set) var size: Int = 0 {
        didSet {
            sizeKnown = size == -1 ? false : true
        }
    }

    // MARK: - Private Properties

    private var urlSession = URLSession(configuration: .ephemeral)
    private var position: Int = 0
    private var sizeKnown: Bool = false
    private let processQueue = DispatchQueue(label: "io.9labs.Checksum.http-source-process")
    private let semaphore = DispatchSemaphore(value: 0)
    private let requestTimeOut: TimeInterval = 5.0

    // MARK: - Lifecycle

    required init?(provider url: URL) {
        self.provider = url

        if let size = getContentLength(for: url) {
            self.size = size
        } else {
            return nil
        }
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
        if sizeKnown, position >= size {
            return nil
        }

        var readData: Data?

        processQueue.sync {
            var request = URLRequest(url: provider, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: requestTimeOut)

            request.httpShouldUsePipelining = true

            if !sizeKnown {
                // Size is unknown
                request.addValue("bytes=\(position)-", forHTTPHeaderField: "Range")
            } else {
                let bytesToRead = Swift.min(amount, size - position)
                let range: (Int, Int) = (position, position + bytesToRead - 1)
                request.addValue("bytes=\(range.0)-\(range.1)", forHTTPHeaderField: "Range")
            }

            let task = urlSession.dataTask(with: request) { data, response, _ in
                defer { self.semaphore.signal() }

                guard let httpResponse = response as? HTTPURLResponse,
                    httpResponse.statusCode == 206,
                    let contentRange = httpResponse.contentRange,
                    let data = data else { return }

                if !self.sizeKnown {
                    // Use expected response's content length for now
                    self.size = Int(httpResponse.expectedContentLength)
                }

                readData = data

                self.position = contentRange.range.lowerBound + data.count

                if data.count < amount {
                    // EOF reached, adjust size.
                    self.size = self.position
                }
            }

            task.resume()
        }

        _ = semaphore.wait(timeout: .distantFuture)

        return readData
    }

    func close() {
        urlSession.invalidateAndCancel()
    }

    // MARK: - Private Functions

    /// Tries to obtain the `URL`'s content length by performing a `HEAD` request. Returns `nil` if it fails.
    private func getContentLength(for url: URL) -> Int? {
        var size: Int?

        processQueue.sync {
            var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: requestTimeOut)

            request.httpShouldUsePipelining = true
            request.httpMethod = "HEAD"

            let task = urlSession.dataTask(with: request) { _, response, error in
                if error == nil, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    size = Int(httpResponse.expectedContentLength)
                }

                self.semaphore.signal()
            }

            task.resume()
        }

        _ = semaphore.wait(timeout: .distantFuture)

        return size
    }
}
