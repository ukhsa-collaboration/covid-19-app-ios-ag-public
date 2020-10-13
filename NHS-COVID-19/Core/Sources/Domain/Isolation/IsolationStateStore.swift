//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Foundation

public protocol SymptomsOnsetDateAndEncounterDateProviding {
    func provideSymptomsOnsetDate() -> Date?
    func provideEncounterDate() -> Date?
}

struct IsolationStateInfo: Codable, Equatable, DataConvertible {
    var isolationInfo: IsolationInfo
    var configuration: IsolationConfiguration
}

class IsolationStateStore: SymptomsOnsetDateAndEncounterDateProviding {
    
    @Encrypted private var isolationStateInfoStorage: IsolationStateInfo?
    
    private let latestConfiguration: () -> IsolationConfiguration
    
    @Published var isolationStateInfo: IsolationStateInfo? {
        didSet {
            isolationStateInfoStorage = isolationStateInfo
        }
    }
    
    var isolationInfo: IsolationInfo {
        isolationStateInfo?.isolationInfo ?? .empty
    }
    
    var configuration: IsolationConfiguration {
        isolationStateInfo?.configuration ?? latestConfiguration()
    }
    
    init(store: EncryptedStoring, latestConfiguration: @escaping () -> IsolationConfiguration) {
        self.latestConfiguration = latestConfiguration
        _isolationStateInfoStorage = store.encrypted("isolation_state_info")
        isolationStateInfo = _isolationStateInfoStorage.wrappedValue
    }
    
    @discardableResult
    func set(_ indexCaseInfo: IndexCaseInfo) -> IsolationLogicalState {
        let isolationInfo = mutating(self.isolationInfo) {
            $0.indexCaseInfo = indexCaseInfo
            $0.hasAcknowledgedEndOfIsolation = false
            $0.hasAcknowledgedStartOfIsolation = true
        }
        
        let logicalState = IsolationLogicalState(today: .today, info: isolationInfo, configuration: configuration)
        if logicalState.isolation?.isIndexCase == true {
            return save(isolationInfo)
        } else {
            return logicalState
        }
        
    }
    
    @discardableResult
    func set(_ contactCaseInfo: ContactCaseInfo) -> IsolationLogicalState {
        let isolationInfo = mutating(self.isolationInfo) {
            $0.contactCaseInfo = contactCaseInfo
            $0.hasAcknowledgedEndOfIsolation = false
        }
        return save(isolationInfo)
    }
    
    func newIsolationStateInfo(for testResult: TestResult, receivedOn: GregorianDay, npexDay: GregorianDay) -> IsolationStateInfo {
        let isolationInfo = mutating(self.isolationInfo) {
            if var indexCaseInfo = $0.indexCaseInfo, testResult == .negative || indexCaseInfo.testInfo?.result != .negative {
                indexCaseInfo.set(testResult: testResult, receivedOn: receivedOn)
                $0.indexCaseInfo = indexCaseInfo
            } else {
                $0.indexCaseInfo = IndexCaseInfo(
                    isolationTrigger: .manualTestEntry(npexDay: npexDay),
                    onsetDay: nil,
                    testInfo: IndexCaseInfo.TestInfo(result: testResult, receivedOnDay: receivedOn)
                )
            }
        }
        return IsolationStateInfo(isolationInfo: isolationInfo, configuration: configuration)
    }
    
    func acknowldegeEndOfIsolation() {
        let isolationInfo = mutating(self.isolationInfo) {
            $0.hasAcknowledgedEndOfIsolation = true
        }
        _ = save(isolationInfo)
    }
    
    func acknowldegeStartOfIsolation() {
        let isolationInfo = mutating(self.isolationInfo) {
            $0.hasAcknowledgedStartOfIsolation = true
        }
        _ = save(isolationInfo)
    }
    
    func restartIsolationAcknowledgement() {
        let isolationInfo = mutating(self.isolationInfo) {
            $0.hasAcknowledgedStartOfIsolation = true
            $0.hasAcknowledgedEndOfIsolation = false
        }
        _ = save(isolationInfo)
    }
    
    private func save(_ isolationInfo: IsolationInfo) -> IsolationLogicalState {
        let configuration = self.configuration
        isolationStateInfo = IsolationStateInfo(
            isolationInfo: isolationInfo,
            configuration: configuration
        )
        
        return IsolationLogicalState(today: .today, info: isolationInfo, configuration: configuration)
    }
    
    func provideEncounterDate() -> Date? {
        guard let encounterDay = isolationInfo.contactCaseInfo?.exposureDay else {
            return nil
        }
        return LocalDay(gregorianDay: encounterDay, timeZone: .current).startOfDay
    }
    
    func provideSymptomsOnsetDate() -> Date? {
        if let onsetDay = isolationInfo.indexCaseInfo?.onsetDay {
            return LocalDay(gregorianDay: onsetDay, timeZone: .current).startOfDay
        }
        
        if case .selfDiagnosis(let selfDiagnosisDay) = isolationInfo.indexCaseInfo?.isolationTrigger {
            // onsetDay = selfDiagnosisDay - 2
            let selfDiagnosisDate = LocalDay(gregorianDay: selfDiagnosisDay, timeZone: .current).startOfDay
            return Calendar.current.date(byAdding: DateComponents(day: -2), to: selfDiagnosisDate)!
        }
        
        return nil
    }
    
    func recordMetrics() -> AnyPublisher<Void, Never> {
        if isolationStateInfo?.isolationInfo.contactCaseInfo != nil {
            Metrics.signpost(.contactCaseBackgroundTick)
        }
        if isolationStateInfo?.isolationInfo.contactCaseInfo != nil {
            Metrics.signpost(.indexCaseBackgroundTick)
        }
        
        return Empty().eraseToAnyPublisher()
    }
    
    func stopSelfIsolation() {
        guard let indexCaseInfo = isolationStateInfo?.isolationInfo.indexCaseInfo else {
            return
        }
        
        guard case .selfDiagnosis = indexCaseInfo.isolationTrigger else {
            return
        }
        
        // Isolation remains unchanged if test result is positive or void
        if indexCaseInfo.testInfo?.result == nil || indexCaseInfo.testInfo?.result == .negative {
            isolationStateInfo = nil
        }
    }
}
