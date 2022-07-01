//
// Copyright © 2020 NHSX. All rights reserved.
//

import Domain
import XCTest

class ZIPManagerTests: XCTestCase {

    func testExtractFiles() throws {
        let zipManager = ZIPManager(data: getZip())
        let folderURL: URL
        do {
            let fileManager = FileManager()
            let handler = try zipManager.extract(fileManager: fileManager)
            folderURL = handler.folderURL
            let content = try fileManager.contentsOfDirectory(
                at: handler.folderURL,
                includingPropertiesForKeys: nil
            ).map { $0.lastPathComponent }

            let expectedSet: Set<String> = ["export.sig", "export.bin"]
            XCTAssertEqual(expectedSet, Set(content))
        }

        // Folder is deleted when the handler goes out of scope
        XCTAssertFalse(FileManager.default.fileExists(atPath: folderURL.path))
    }

    func getZip() -> Data {
        let base64Zip = "UEsDBBQACAAIAAAAAAAAAAAAAAAAAAAAAAAKAAAAZXhwb3J0LmJpbnL1VnCtKMgvKlEoM1RQUFDg/PDieBwDAwODYIHVSTBDiik0WIFRg9FIUYrRUIm9OD83NT4zRUvYUM9Iz8LEQM/QwMDEVM9Ez1jPyEqaS0Bc/0jD0xmePCbiZSzGs0WdBTgk/txbyKjACJLUTma1OtKs3PuwTGxem7ztWQFGiS6QZBEgAAD//1BLBwhQGAPXhwAAAIcAAABQSwMEFAAIAAgAAAAAAAAAAAAAAAAAAAAAAAoAAABleHBvcnQuc2ln4irkUpRiNFRiL87PTY3PTNESNtQz0rMwMdAzNDAwMdUz0TPWMxJglGBU8jBwY1JkmLft5dW1WRn9Kws2PKvhaDOJe39XQjJS725LgpfMeV8mdyZFhgm59Wc/CR4X+OGlVSnOwFq878N79SXTHTXvaZStyZD8lgUIAAD//1BLBwhEY4HtfAAAAHMAAABQSwECFAAUAAgACAAAAAAAUBgD14cAAACHAAAACgAAAAAAAAAAAAAAAAAAAAAAZXhwb3J0LmJpblBLAQIUABQACAAIAAAAAABEY4HtfAAAAHMAAAAKAAAAAAAAAAAAAAAAAL8AAABleHBvcnQuc2lnUEsFBgAAAAACAAIAcAAAAHMBAAAAAA=="
        let decodedData = Data(base64Encoded: base64Zip)!
        return decodedData
    }
}
