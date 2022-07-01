//
// Copyright © 2020 NHSX. All rights reserved.
//

import XCTest
@testable import Domain

class FileStoredTests: XCTestCase {

    private let fileManager = FileManager()
    private var folder: URL!
    private var storage: FileStorage!
    private var fileName: String!
    private var url: URL!

    override func setUpWithError() throws {
        folder = try fileManager.url(for: .itemReplacementDirectory, in: .userDomainMask, appropriateFor: Bundle.main.bundleURL, create: true)
        storage = FileStorage(directory: folder)

        fileName = UUID().uuidString
        url = folder.appendingPathComponent(fileName)

        addTeardownBlock {
            try? self.fileManager.removeItem(at: self.folder)
        }
    }

    func testCanSetValueInFile() throws {
        let value = "test".data(using: .utf8)

        let fileStored = FileStored<Data>(storage: storage, name: fileName)
        fileStored.wrappedValue = value
        XCTAssertEqual(try Data(contentsOf: url), value)
    }

    func testGetValueFromFile() throws {
        let value = "test".data(using: .utf8)
        try value?.write(to: url)

        let fileStored = FileStored<Data>(storage: storage, name: fileName)
        XCTAssertEqual(fileStored.wrappedValue, value)
    }

    func testGetNilWhenNoFile() throws {
        let fileStored = FileStored<Data>(storage: storage, name: fileName)
        XCTAssertNil(fileStored.wrappedValue)
    }

    func testCanDeleteFile() throws {
        let value = "test".data(using: .utf8)

        let fileStored = FileStored<Data>(storage: storage, name: fileName)
        fileStored.wrappedValue = value
        fileStored.wrappedValue = nil
        XCTAssertFalse(fileStored.hasValue)
    }

    func testHasValueReturnsTrueWhenFileExists() throws {
        let value = "test".data(using: .utf8)

        let fileStored = FileStored<Data>(storage: storage, name: fileName)
        fileStored.wrappedValue = value
        XCTAssertTrue(fileStored.hasValue)
    }
}
