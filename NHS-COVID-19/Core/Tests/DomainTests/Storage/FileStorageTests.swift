//
// Copyright © 2020 NHSX. All rights reserved.
//

import Domain
import Foundation
import TestSupport
import XCTest

class FileStorageTests: XCTestCase {
    
    private let fileManager = FileManager()
    private var folder: URL!
    private var storage: FileStorage!
    
    override func setUpWithError() throws {
        
        let documentFolder = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        
        folder = try fileManager.url(for: .itemReplacementDirectory, in: .userDomainMask, appropriateFor: documentFolder, create: true)
        storage = FileStorage(directory: folder)
        
        addTeardownBlock {
            try? self.fileManager.removeItem(at: self.folder)
        }
    }
    
    func testSave() throws {
        
        let expected = Data.random()
        let file = String.random()
        
        storage.save(expected, to: file)
        
        let actual = try Data(contentsOf: folder.appendingPathComponent(file))
        
        XCTAssertEqual(actual, expected)
        
    }
    
    func testSaveSetsNoBackupAttribute() throws {
        
        let expected = Data.random()
        let file = String.random()
        
        storage.save(expected, to: file)
        
        let isExcludedFromBackup = try folder
            .appendingPathComponent(file)
            .resourceValues(forKeys: [.isExcludedFromBackupKey])
            .isExcludedFromBackup
        
        XCTAssert(try XCTUnwrap(isExcludedFromBackup))
        
    }
    
    func testRead() throws {
        
        let expected = Data.random()
        let file = String.random()
        
        try expected.write(to: folder.appendingPathComponent(file))
        
        let actual = storage.read(file)
        
        XCTAssertEqual(actual, expected)
        
    }
    
    func testDelete() throws {
        
        let expected = Data.random()
        let file = String.random()
        
        try expected.write(to: folder.appendingPathComponent(file))
        
        storage.delete(file)
        
        XCTAssertThrowsError(try Data(contentsOf: folder.appendingPathComponent(file)))
        
    }
    
    func testHasContent() throws {
        
        let expected = Data.random()
        let file = String.random()
        
        XCTAssertFalse(storage.hasContent(for: "file"))
        
        try expected.write(to: folder.appendingPathComponent(file))
        
        XCTAssertTrue(storage.hasContent(for: file))
    }
    
    func testHasContentDoesNotConsiderFolders() throws {
        
        XCTAssertFalse(storage.hasContent(for: ""))
        
    }
    
}
