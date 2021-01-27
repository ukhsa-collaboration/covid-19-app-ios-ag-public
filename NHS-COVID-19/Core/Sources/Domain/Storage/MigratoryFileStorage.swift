//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

#warning("We should be able to remove this in a few months")
// Written in Jan 2020
public class MigratoryFileStorage: FileStoring {
    
    private let newStorage: FileStoring
    private let oldStorage: FileStoring
    
    public init(newStorage: FileStoring, oldStorage: FileStoring) {
        self.newStorage = newStorage
        self.oldStorage = oldStorage
    }
    
    public func save(_ data: Data, to file: String) {
        newStorage.save(data, to: file)
        oldStorage.delete(file)
    }
    
    public func read(_ file: String) -> Data? {
        newStorage.read(file) ?? oldStorage.read(file)
    }
    
    public func hasContent(for file: String) -> Bool {
        newStorage.hasContent(for: file) || oldStorage.hasContent(for: file)
    }
    
    public func delete(_ file: String) {
        newStorage.delete(file)
        oldStorage.delete(file)
    }
    
    public func modificationDate(_ file: String) -> Date? {
        newStorage.modificationDate(file) ?? oldStorage.modificationDate(file)
    }
    
    public func allFileNames() -> [String]? {
        #warning("This is assuming that even though we return an array we treat it as a set. please confirm.")
        var names = Set<String>()
        if let n = newStorage.allFileNames() {
            names = names.union(n)
        }
        if let n = oldStorage.allFileNames() {
            names = names.union(n)
        }
        return Array(names)
    }
    
}
