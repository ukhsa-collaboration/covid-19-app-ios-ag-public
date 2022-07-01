//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
import ZIPFoundation

public class ZIPManager {
    public class Handler {
        private let fileManager: FileManager
        public var folderURL: URL

        fileprivate init(folderURL: URL, fileManager: FileManager) {
            self.folderURL = folderURL
            self.fileManager = fileManager
        }

        deinit {
            delete()
        }

        private func delete() {
            try? fileManager.removeItem(at: folderURL)
        }
    }

    private let data: Data

    public init(data: Data) {
        self.data = data
    }

    public func extract(fileManager: FileManager) throws -> Handler {
        let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let tempFolder = cachesDirectory.appendingPathComponent(UUID().uuidString)
        return try extract(to: tempFolder, fileManager: fileManager)

    }

    private func extract(to folderURL: URL, fileManager: FileManager) throws -> Handler {
        let archive = Archive(data: data, accessMode: .read)
        try archive?.forEach { entry in
            let name = entry.path
            let entryFile = folderURL.appendingPathComponent(name)
            _ = try archive?.extract(entry, to: entryFile)
        }

        return Handler(folderURL: folderURL, fileManager: fileManager)
    }
}
