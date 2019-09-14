//
//  Source.swift
//  Checksum
//
//  Created by Ruben Nine on 10/5/18.
//  Copyright © 2018 9Labs. All rights reserved.
//

import Foundation

protocol Source {
    var size: Int { get }

    func seek(position: Int) -> Bool
    func tell() -> Int
    func read(amount: Int) -> Data?
    func eof() -> Bool
}

protocol InstantiableSource: Source {
    associatedtype Provider

    var provider: Provider { get }

    init?(provider: Provider)
}
