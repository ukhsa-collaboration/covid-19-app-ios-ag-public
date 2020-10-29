//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Foundation

class DiagnosisKeyCacheHousekeeper {
    private static let twentyFourHours: Double = 24 * 60 * 60
    private let fileStorage: FileStoring
    private let nextIncrementIdentifiers: () -> [String]
    private let currentDateProvider: () -> Date
    
    init(
        fileStorage: FileStoring,
        exposureDetectionStore: ExposureDetectionStore,
        currentDateProvider: @escaping () -> Date
    ) {
        self.fileStorage = fileStorage
        nextIncrementIdentifiers = {
            if let lastKeyDownloadDate = exposureDetectionStore.load()?.lastKeyDownloadDate {
                var nextIncrements = [String]()
                var lastCheckDate = lastKeyDownloadDate
                let now = currentDateProvider()
                while let incrementInfo = Increment.nextIncrement(lastCheckDate: lastCheckDate, now: now) {
                    nextIncrements.append(incrementInfo.increment.identifier)
                    lastCheckDate = incrementInfo.checkDate
                }
                return nextIncrements
            } else { return [] }
        }
        self.currentDateProvider = currentDateProvider
    }
    
    func deleteFilesOlderThanADay() -> AnyPublisher<Void, Never> {
        Future<Void, Never> { [weak self] promise in
            guard let self = self else {
                promise(.success(()))
                return
            }
            
            let allFiles = self.fileStorage.allFileNames()
            let validUntil = self.currentDateProvider().advanced(by: -Self.twentyFourHours)
            allFiles?.forEach { fileName in
                if fileName.starts(with: Increment.IdentifierPrefix) {
                    if let modificationDate = self.fileStorage.modificationDate(fileName) {
                        if modificationDate < validUntil {
                            self.fileStorage.delete(fileName)
                        }
                    } else {
                        self.fileStorage.delete(fileName)
                    }
                }
            }
            promise(.success(()))
            
        }
        .eraseToAnyPublisher()
    }
    
    func deleteNotNeededFiles() -> AnyPublisher<Void, Never> {
        Future<Void, Never> { [weak self] promise in
            guard let self = self else {
                promise(.success(()))
                return
            }
            
            let nextIncrementIdentifiers = self.nextIncrementIdentifiers()
            let allFiles = self.fileStorage.allFileNames()
            allFiles?.forEach { fileName in
                if fileName.starts(with: Increment.IdentifierPrefix), !nextIncrementIdentifiers.contains(fileName) {
                    self.fileStorage.delete(fileName)
                }
            }
            promise(.success(()))
        }
        .eraseToAnyPublisher()
    }
}
