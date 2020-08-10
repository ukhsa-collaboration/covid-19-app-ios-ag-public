//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

public class FileStorage {
    
    private let fileManager = FileManager()
    private let directory: URL
    
    public init(directory: URL) {
        self.directory = directory
    }
    
    public func save(_ data: Data, to file: String) {
        var url = self.url(for: file)
        try? data.write(to: url)
        
        var resourceValues = URLResourceValues()
        resourceValues.isExcludedFromBackup = true
        try? url.setResourceValues(resourceValues)
    }
    
    public func read(_ file: String) -> Data? {
        try? Data(contentsOf: url(for: file))
    }
    
    public func hasContent(for file: String) -> Bool {
        var isDirectory: ObjCBool = true
        return fileManager.fileExists(atPath: url(for: file).path, isDirectory: &isDirectory) && !isDirectory.boolValue
    }
    
    public func delete(_ file: String) {
        try? fileManager.removeItem(at: url(for: file))
    }
    
    private func url(for file: String) -> URL {
        directory.appendingPathComponent(file)
    }
}

public extension FileStorage {
    
    convenience init(forDocumentsOf service: String) {
        let fileManager = FileManager()
        let folder = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(service)
        try? fileManager.createDirectory(at: folder, withIntermediateDirectories: false, attributes: nil)
        self.init(directory: folder)
    }
    
    convenience init(forCachesOf service: String) {
        let fileManager = FileManager()
        let folder = try! fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(service)
        try? fileManager.createDirectory(at: folder, withIntermediateDirectories: false, attributes: nil)
        self.init(directory: folder)
    }
    
}
