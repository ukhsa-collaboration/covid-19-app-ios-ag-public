//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

struct ASN1Scanner {

    private struct Tag {
        var rawValue: UInt8
        static let integer = Tag(rawValue: 0x02)
        static let bitString = Tag(rawValue: 0x03)
        static let octet = Tag(rawValue: 0x04)
        static let objectIdentifier = Tag(rawValue: 0x06)
        static let sequence = Tag(rawValue: 0x30)
        static func tagged(_ value: UInt8) -> Tag {
            Tag(rawValue: value + 0xa0)
        }
    }

    private enum Errors: Error {
        case invalidStream
    }

    var stream: Data

    init(data: Data) {
        stream = data
    }

    @discardableResult
    mutating func scanSequenceHeader() throws -> Int {
        try scanLength(for: .sequence)
    }

    @discardableResult
    mutating func scanTagHeader(_ value: UInt8) throws -> Int {
        try scanLength(for: .tagged(value))
    }

    @discardableResult
    mutating func scanInteger() throws -> Data {
        try scanData(for: .integer)
    }

    @discardableResult
    mutating func scanBitString() throws -> Data {
        try scanData(for: .bitString)
    }

    @discardableResult
    mutating func scanOctet() throws -> Data {
        try scanData(for: .octet)
    }

    @discardableResult
    mutating func scanObjectIdentifier() throws -> Data {
        try scanData(for: .objectIdentifier)
    }

    @discardableResult
    mutating func scanTag(_ value: UInt8) throws -> Data {
        try scanData(for: .tagged(value))
    }

    @discardableResult
    private mutating func scanData(for tag: Tag) throws -> Data {
        let length = try scanLength(for: tag)

        defer {
            stream = stream.dropFirst(length)
        }
        return stream.prefix(length)
    }

    @discardableResult
    private mutating func scanLength(for tag: Tag) throws -> Int {
        guard stream.popFirst() == tag.rawValue, !stream.isEmpty else {
            throw Errors.invalidStream
        }

        let first = stream.popFirst()!
        let length: Int
        if first & 0x80 == 0x00 {
            length = Int(first)
        } else {
            let lenghOfLength = Int(first & 0x7F)
            guard stream.count >= lenghOfLength else {
                throw Errors.invalidStream
            }

            var result = 0
            for _ in 0 ..< lenghOfLength {
                result = 256 * result + Int(stream.popFirst()!)
            }
            length = result
        }

        guard stream.count >= length else {
            throw Errors.invalidStream
        }

        return length
    }

}
