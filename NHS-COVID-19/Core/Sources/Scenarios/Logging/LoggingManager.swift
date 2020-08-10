//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation
import Logging

public class LoggingManager {
    
    private static let consoleMinimumLogLevel = Logger.Level.debug
    
    @Published
    var logs = ""
    
    private let io = DispatchQueue(label: "Logging IO")
    private let stream = OutputStream.makeForLogs()
    
    public init() {
        stream.open()
    }
    
    public func makeLogHandler(label: String) -> LogHandler {
        ForwardingLogHandler(label: label, send: log)
    }
    
    private func log(_ event: LogEvent) {
        let entry = "\(event.description())\n"
        if event.level >= Self.consoleMinimumLogLevel {
            print(event.description(verbosity: .standard))
        }
        
        DispatchQueue.main.async {
            self.logs.append(entry)
            self.logs.append("\n")
        }
        io.async {
            let data = entry.data(using: .utf8)!
            data.withUnsafeBytes { buffer in
                let bytes = buffer.bindMemory(to: UInt8.self)
                self.stream.write(bytes.baseAddress!, maxLength: bytes.count)
            }
        }
    }
    
}

extension LogEvent {
    
    enum Verbosity {
        case standard
        case detailed
    }
    
    func description(verbosity: Verbosity = .standard) -> String {
        let headline = self.headline(verbosity: verbosity)
        if let metadata = self.metadata, !metadata.isEmpty {
            return "\(headline)\n\(metadata.description)"
        } else {
            return headline
        }
    }
    
    private func headline(verbosity: Verbosity) -> String {
        switch verbosity {
        case .standard:
            return "\(formatter.string(from: date)) \(level): \(label) – \(message)"
        case .detailed:
            return "\(formatter.string(from: date)) \(level): \(label) \(fileName):\(line):\(function) – \(message)"
        }
    }
    
    private var fileName: String {
        file.components(separatedBy: "/").last!
    }
    
}

private extension Logger.Metadata {
    
    var description: String {
        if
            count == 1,
            case .stringConvertible(let value)? = self["value"],
            let described = value as? DescribedValue {
            // especial behaviour:
            // `DescribedValue` wraps a value that we want to generate the log from.
            // But we don’t actually want to _ship_ the description generator in production.
            // So instead, we just hold on to the value itself and generate its description manually here
            return customDescription(for: described.value)
        } else {
            var string = ""
            appendDescription(into: &string)
            return string
        }
    }
    
    func appendDescription(into description: inout String, depth: Int = 0) {
        let whitespace = repeatElement("  ", count: depth).joined()
        sorted { $0.key < $1.key }
            .forEach { key, value in
                description.append("\(whitespace)\(key): ")
                value.appendDescription(into: &description, depth: depth + 1)
            }
    }
    
}

private extension Logger.MetadataValue {
    
    func appendDescription(into description: inout String, depth: Int) {
        switch self {
        case .string(let string):
            description.append(string)
            description.append("\n")
        case .stringConvertible(let convertible):
            description.append(convertible.description)
            description.append("\n")
        case .dictionary(let dictionary):
            description.append("\n")
            dictionary.appendDescription(into: &description, depth: depth)
        case .array(let array):
            description.append("\n")
            array.forEach { value in
                let whitespace = repeatElement("  ", count: depth).joined()
                description.append("\(whitespace)- ")
                value.appendDescription(into: &description, depth: depth + 1)
            }
        }
    }
    
}

private let formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_UK_POSIX")
    formatter.dateStyle = .none
    formatter.timeStyle = .medium
    return formatter
}()

private extension OutputStream {
    
    static func makeForLogs() -> OutputStream {
        let fileManager = FileManager()
        let fileName = ISO8601DateFormatter().string(from: Date())
        
        // Don’t really expect an error, but don’t want to crash because of this.
        guard let logsFolder = try? fileManager
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("Logs") else {
            return OutputStream(toMemory: ())
        }
        
        try? fileManager.createDirectory(at: logsFolder, withIntermediateDirectories: true, attributes: nil)
        
        let file = logsFolder.appendingPathComponent("\(fileName).log")
        
        return OutputStream(url: file, append: false) ?? OutputStream(toMemory: ())
    }
    
}

// TODO: This logic is duplicate with Test support. Can we unify?

private func customDescription(for subject: Any) -> String {
    let object = descriptionObject(for: subject)
    switch descriptionObject(for: subject) {
    case .dictionary, .array, .jsonObject:
        let json = try! JSONSerialization.data(withJSONObject: object.jsonObject, options: [.prettyPrinted, .sortedKeys])
        return String(data: json, encoding: .utf8)!
    case .string(let string):
        return string
    case .null:
        return "<Null>"
    }
}

private protocol CustomDescriptionConvertible {
    var descriptionObject: Description { get }
}

private enum Description {
    case string(String)
    case dictionary([String: Description])
    case array([Description])
    case jsonObject(Any)
    case null
    
    var jsonObject: Any {
        switch self {
        case .string(let value):
            return value
        case .dictionary(let value):
            return value.mapValues { $0.jsonObject }
        case .array(let value):
            return value.map { $0.jsonObject }
        case .jsonObject(let object):
            return object
        case .null:
            return NSNull()
        }
    }
    
    public static func encodable<T: Encodable>(_ object: T) -> Description {
        let data = try! JSONEncoder().encode(object)
        let object = try! JSONSerialization.jsonObject(with: data)
        return .jsonObject(object)
    }
}

private func descriptionObject(for subject: Any) -> Description {
    if let convertible = subject as? CustomDescriptionConvertible {
        return convertible.descriptionObject
    }
    let mirror = Mirror(reflecting: subject)
    switch mirror.displayStyle ?? .struct {
    case .struct, .class:
        guard !mirror.children.isEmpty else {
            return .string("\(subject)")
        }
        var dictionary = [String: Description]()
        var instanceMirror: Mirror? = mirror
        while instanceMirror != nil {
            instanceMirror?.children.forEach { key, value in
                if let key = key {
                    dictionary[key] = descriptionObject(for: value)
                }
            }
            instanceMirror = instanceMirror?.superclassMirror
        }
        
        return .dictionary(dictionary)
        
    case .optional:
        var value: Any?
        mirror.children.forEach { _, child in
            value = child
        }
        if let value = value {
            return descriptionObject(for: value)
        } else {
            return .null
        }
        
    case .collection:
        let array = mirror.children.map { _, child in
            descriptionObject(for: child)
        }
        return .array(array)
        
    case .set:
        let array = mirror.children
            .sorted { "\($0.1)" < "\($1.1)" } // doesn’t matter as long as it’s predictable
            .map { _, child in
                descriptionObject(for: child)
            }
        return .array(array)
        
    case .dictionary:
        var dictionary = [String: Description]()
        mirror.children.forEach { _, child in
            var key: String?
            var value: Any?
            Mirror(reflecting: child).children.forEach { label, subchild in
                switch label {
                case "key":
                    key = subchild as? String
                case "value":
                    value = subchild
                default:
                    break
                }
            }
            if let key = key, let value = value {
                dictionary[key] = descriptionObject(for: value)
            }
        }
        return .dictionary(dictionary)
        
    case .enum, .tuple:
        // Not worth the effort at the moment. Refine if the need comes up.
        return .string("\(subject)")
        
    @unknown default:
        return .string("\(subject)")
    }
}

extension HTTPRequest: CustomDescriptionConvertible {
    
    private static let fakeRemote = HTTPRemote(host: "a.com", path: "")
    
    fileprivate var descriptionObject: Description {
        let request = try! Self.fakeRemote.urlRequest(from: self)
        let path = request.url!.absoluteString.replacingOccurrences(of: "https://a.com", with: "")
        let description = [
            "\(method.rawValue) \(path)",
            headerDescription,
            bodyDescription,
        ]
        .compactMap { $0 }
        .joined(separator: "\n")
        return .string(description)
    }
    
    private var headerDescription: String? {
        guard !headers.fields.isEmpty else { return nil }
        
        let lines = headers.fields.sorted { $0.0.lowercaseName < $1.0.lowercaseName }
            .map { "    \($0.lowercaseName): \($1)" }
            .joined(separator: "\n")
        
        return "Headers:\n\(lines)"
    }
    
    private var bodyDescription: String? {
        guard let body = body else { return "" }
        
        return String(data: body.content, encoding: .utf8) ?? ""
    }
    
}

extension HTTPResponse: CustomDescriptionConvertible {
    
    fileprivate var descriptionObject: Description {
        let description = [
            "\(statusCode)",
            headerDescription,
            bodyDescription,
        ]
        .compactMap { $0 }
        .joined(separator: "\n")
        return .string(description)
    }
    
    private var headerDescription: String? {
        guard !headers.fields.isEmpty else { return nil }
        
        let lines = headers.fields.sorted { $0.0.lowercaseName < $1.0.lowercaseName }
            .map { "    \($0.lowercaseName): \($1)" }
            .joined(separator: "\n")
        
        return "Headers:\n\(lines)"
    }
    
    private var bodyDescription: String {
        String(data: body.content, encoding: .utf8) ?? ""
    }
    
}
