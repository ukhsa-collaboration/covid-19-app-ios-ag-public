//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

struct XcodeConfiguration {

    enum Line {
        case decoration(text: String)
        case configuration(name: String, value: String)

        init<S: StringProtocol>(text: S) {
            let parts = text.components(separatedBy: "=")
            switch parts.count {
            case 2:
                self = .configuration(
                    name: parts[0].trimmingCharacters(in: .whitespaces),
                    value: parts[1].trimmingCharacters(in: .whitespaces)
                )
            default:
                self = .decoration(text: String(text))
            }
        }
    }

    var url: URL
    var lines: [Line]

    init(url: URL) throws {
        self.url = url
        lines = try String(contentsOf: url)
            .split(separator: "\n")
            .map(Line.init)
    }

    func save() throws {
        try lines.lazy.map { $0.text }.joined(separator: "\n")
            .write(to: url, atomically: true, encoding: .utf8)
    }

    func value(for name: String) throws -> String {
        guard let value = lines.last(where: { $0.name == name })?.value else {
            throw CustomError("No value for configuration “\(name)”")
        }
        return value
    }

}

extension XcodeConfiguration.Line {

    var name: String? {
        switch self {
        case .decoration:
            return nil
        case .configuration(let name, _):
            return name
        }
    }

    var value: String? {
        switch self {
        case .decoration:
            return nil
        case .configuration(_, let value):
            return value
        }
    }

    var text: String {
        switch self {
        case .decoration(let text):
            return text
        case .configuration(let name, let value):
            return "\(name) = \(value)"
        }
    }

}
