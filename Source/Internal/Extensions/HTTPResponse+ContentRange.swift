//
//  HTTPResponse+ContentRange.swift
//  Checksum
//
//  Created by Ruben Nine on 19/09/2019.
//  Copyright © 2019 9Labs. All rights reserved.
//

import Foundation

extension HTTPURLResponse {

    var contentRange: (range: ClosedRange<Int>, size: Int?)? {
        guard let rangeString = allHeaderFields["Content-Range"] as? String else { return nil }

        let regex = try? NSRegularExpression(
          pattern: "bytes (\\d+)-(\\d+)\\/(\\S*)",
          options: .caseInsensitive
        )

        let scanRange = NSRange(location: 0, length: rangeString.utf16.count)

        guard let match = regex?.firstMatch(in: rangeString, options: [], range: scanRange) else { return nil }
        guard let match1 = Range(match.range(at: 1), in: rangeString),
            let match2 = Range(match.range(at: 2), in: rangeString),
            let match3 = Range(match.range(at: 3), in: rangeString) else { return nil }
        guard let start = Int(rangeString[match1]), let end = Int(rangeString[match2]) else { return nil }

        let size = Int(rangeString[match3])

        return (range: (start...end), size: size)
    }
}
