//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
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

    func testAllFileNames() throws {
        let content = Data.random()
        let file1 = String.random()
        let file2 = String.random()
        let file3 = String.random()

        try content.write(to: folder.appendingPathComponent(file1))
        try content.write(to: folder.appendingPathComponent(file2))
        try content.write(to: folder.appendingPathComponent(file3))

        let allFileNames = try XCTUnwrap(storage.allFileNames())
        XCTAssertEqual(allFileNames.count, 3)
        XCTAssertTrue(allFileNames.contains(file1))
        XCTAssertTrue(allFileNames.contains(file2))
        XCTAssertTrue(allFileNames.contains(file3))
    }

    func testModificationDate() throws {
        let date = UTCHour(year: 2020, month: 10, day: 1, hour: 22).date
        let content = Data.random()
        let fileName = "file"
        try content.write(to: folder.appendingPathComponent(fileName))
        try fileManager.setAttributes([.modificationDate: date], ofItemAtPath: folder.appendingPathComponent(fileName).path)

        XCTAssertEqual(date, storage.modificationDate(fileName))
    }

}
