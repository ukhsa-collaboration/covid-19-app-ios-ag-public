//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Scenarios
import XCTest
@testable import Domain

class DiagnosisKeyCacheHousekeeperTests: XCTestCase {
    private var fileStorage: MockFileStorage!
    private var exposureDetectionStore: ExposureDetectionStore!
    private var currentDate: Date!
    private var cache: DiagnosisKeyCacheHousekeeper!

    override func setUp() {
        fileStorage = MockFileStorage()
        exposureDetectionStore = ExposureDetectionStore(store: MockEncryptedStore())
        cache = DiagnosisKeyCacheHousekeeper(
            fileStorage: fileStorage,
            exposureDetectionStore: exposureDetectionStore,
            currentDateProvider: MockDateProvider { self.currentDate }
        )
    }

    func testDoNotDeleteStillRelevantFiles() throws {
        let keepTwoHourly = Increment.twoHourly(.init(year: 2020, month: 6, day: 26), .init(value: 12))
        fileStorage.save(.random(), to: keepTwoHourly.identifier)
        let keepDaily = Increment.daily(.init(year: 2020, month: 6, day: 26))
        fileStorage.save(.random(), to: keepDaily.identifier)
        let otherFile = "AnyOtherFile"
        fileStorage.save(.random(), to: otherFile)

        currentDate = UTCHour(year: 2020, month: 6, day: 26, hour: 22).date
        let lastDownloadDate = GregorianDay(year: 2020, month: 6, day: 25).startDate(in: .utc)
        exposureDetectionStore.save(lastKeyDownloadDate: lastDownloadDate)

        _ = cache.deleteNotNeededFiles()

        XCTAssertEqual((fileStorage.allFileNames() ?? []).count, 3)
        XCTAssertTrue(fileStorage.hasContent(for: keepTwoHourly.identifier))
        XCTAssertTrue(fileStorage.hasContent(for: keepDaily.identifier))
        XCTAssertTrue(fileStorage.hasContent(for: otherFile))
    }

    func testDeleteOutdatedFiles() throws {
        let outdatedTwoHourly = Increment.twoHourly(.init(year: 2020, month: 6, day: 20), .init(value: 12))
        fileStorage.save(.random(), to: outdatedTwoHourly.identifier)
        let outdatedDaily = Increment.daily(.init(year: 2020, month: 6, day: 20))
        fileStorage.save(.random(), to: outdatedDaily.identifier)
        let otherFile = "AnyOtherFile"
        fileStorage.save(.random(), to: otherFile)

        currentDate = UTCHour(year: 2020, month: 6, day: 26, hour: 22).date
        let lastDownloadDate = GregorianDay(year: 2020, month: 6, day: 25).startDate(in: .utc)
        exposureDetectionStore.save(lastKeyDownloadDate: lastDownloadDate)

        _ = cache.deleteNotNeededFiles()

        XCTAssertEqual((fileStorage.allFileNames() ?? []).count, 1)
        XCTAssertFalse(fileStorage.hasContent(for: outdatedTwoHourly.identifier))
        XCTAssertFalse(fileStorage.hasContent(for: outdatedDaily.identifier))
        XCTAssertTrue(fileStorage.hasContent(for: otherFile))
    }

    func testDeleteFilesOlderThanOneDay() throws {
        let outdated = UTCHour(year: 2020, month: 10, day: 2, hour: 1).date
        let keep = UTCHour(year: 2020, month: 10, day: 14, hour: 12).date
        currentDate = UTCHour(year: 2020, month: 10, day: 15, hour: 2).date

        let outdatedIncrement = Increment.twoHourly(.init(year: 2020, month: 6, day: 20), .init(value: 12))
        fileStorage.save(.random(), to: outdatedIncrement.identifier)
        fileStorage.modificationDate[outdatedIncrement.identifier] = outdated

        let keepIncrement = Increment.twoHourly(.init(year: 2020, month: 6, day: 21), .init(value: 12))
        fileStorage.save(.random(), to: keepIncrement.identifier)
        fileStorage.modificationDate[keepIncrement.identifier] = keep

        _ = cache.deleteFilesOlderThanADay()

        XCTAssertTrue(fileStorage.hasContent(for: keepIncrement.identifier))
        XCTAssertFalse(fileStorage.hasContent(for: outdatedIncrement.identifier))
    }
}

private class MockFileStorage: FileStoring {
    var files = [String]()
    var modificationDate = [String: Date]()

    func save(_ data: Data, to file: String) {
        files.append(file)
    }

    func read(_ file: String) -> Data? {
        return nil
    }

    func hasContent(for file: String) -> Bool {
        files.contains(file)
    }

    func delete(_ file: String) {
        files.removeAll(where: { $0 == file })
    }

    func modificationDate(_ file: String) -> Date? {
        modificationDate[file]
    }

    func allFileNames() -> [String]? {
        files
    }

}
