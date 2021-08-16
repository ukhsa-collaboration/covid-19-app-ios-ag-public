//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Foundation

public protocol SymptomsOnsetDateAndExposureDetailsProviding {
    func provideSymptomsOnsetDate() -> Date?
    func provideExposureDetails() -> (encounterDate: Date,
                                      notificationDate: Date,
                                      optOutOfIsolationDate: Date?)?
}

struct IsolationStateInfo: Equatable {
    var isolationInfo: IsolationInfo
    var configuration: IsolationConfiguration
}

class IsolationStateStore: SymptomsOnsetDateAndExposureDetailsProviding {
    enum Operation: Equatable {
        case nothing
        case ignore
        case deleteSymptoms
        case deleteTest
        case update
        case overwrite
        case confirm
        case complete
        case completeAndDeleteSymptoms
        case updateAndConfirm
        case overwriteAndComplete
        case overwriteAndConfirm
    }
    
    @Encrypted private var isolationStateStoredPayload: IsolationStatePayload?
    
    private let latestConfiguration: () -> IsolationConfiguration
    private let currentDateProvider: DateProviding
    
    @Published var isolationStateInfo: IsolationStateInfo? {
        didSet {
            isolationStateStoredPayload = isolationStateInfo.map(IsolationStatePayload.init)
        }
    }
    
    var isolationInfo: IsolationInfo {
        isolationStateInfo?.isolationInfo ?? IsolationInfo()
    }
    
    var configuration: IsolationConfiguration {
        isolationStateInfo?.configuration ?? latestConfiguration()
    }
    
    init(store: EncryptedStoring, latestConfiguration: @escaping () -> IsolationConfiguration, currentDateProvider: DateProviding) {
        self.latestConfiguration = latestConfiguration
        self.currentDateProvider = currentDateProvider
        _isolationStateStoredPayload = store.encrypted("isolation_state_info")
        isolationStateInfo = _isolationStateStoredPayload.wrappedValue?.isolationStateInfo
    }
    
    @discardableResult
    func set(_ indexCaseInfo: IndexCaseInfo) -> IsolationLogicalState {
        let isolationInfo = mutating(self.isolationInfo) {
            $0.indexCaseInfo = indexCaseInfo
            $0.hasAcknowledgedEndOfIsolation = false
        }
        
        let logicalState = IsolationLogicalState(today: currentDateProvider.currentLocalDay, info: isolationInfo, configuration: configuration)
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
            $0.hasAcknowledgedStartOfContactIsolation = false
        }
        return save(isolationInfo)
    }
    
    func newIsolationStateInfo(from currentIsolationInfo: IsolationInfo?, for unacknowledgedTestResult: UnacknowledgedTestResult, testKitType: TestKitType?, requiresConfirmatoryTest: Bool, confirmatoryDayLimit: Int? = nil, receivedOn: GregorianDay, npexDay: GregorianDay, operation: IsolationStateStore.Operation) -> IsolationStateInfo {
        
        let isolationInfo = mutating(currentIsolationInfo ?? IsolationInfo()) {
            #warning("Improve type-safety here.")
            // If we can not create a `TestResult` here, that means the test is not relevant to isolation, therefore
            // the operation *must* be `.nothing`.
            // This is currently aligned with how `TestResultIsolationOperation` works, but this can’t be conveyed to
            // the type system.
            //
            // Consider refactoring how these methods are called so we can better capture what should happen.
            guard let testResult = TestResult(unacknowledgedTestResult) else {
                assert(operation == .nothing)
                return
            }
            
            if requiresConfirmatoryTest == false, testResult == .positive, operation != .ignore {
                $0.contactCaseInfo = nil
            }
            
            switch operation {
            case .nothing, .ignore:
                return
            case .deleteSymptoms:
                $0.indexCaseInfo = IndexCaseInfo(
                    symptomaticInfo: nil,
                    testInfo: $0.indexCaseInfo?.testInfo
                )
            case .deleteTest:
                $0.indexCaseInfo = IndexCaseInfo(
                    symptomaticInfo: $0.indexCaseInfo?.symptomaticInfo,
                    testInfo: nil
                )
            case .update:
                $0.indexCaseInfo = IndexCaseInfo(
                    symptomaticInfo: $0.indexCaseInfo?.symptomaticInfo,
                    testInfo: IndexCaseInfo.TestInfo(result: testResult, testKitType: testKitType, requiresConfirmatoryTest: requiresConfirmatoryTest, confirmatoryDayLimit: confirmatoryDayLimit, receivedOnDay: receivedOn, testEndDay: npexDay)
                )
            case .complete:
                if var indexCaseInfo = $0.indexCaseInfo {
                    indexCaseInfo.completeTest(completedOnDay: npexDay)
                    $0.indexCaseInfo = indexCaseInfo
                }
            case .completeAndDeleteSymptoms:
                var newIndexCaseInfo = IndexCaseInfo(
                    symptomaticInfo: nil,
                    testInfo: $0.indexCaseInfo?.testInfo
                )
                newIndexCaseInfo?.completeTest(completedOnDay: npexDay)
                $0.indexCaseInfo = newIndexCaseInfo
            case .confirm:
                if var indexCaseInfo = $0.indexCaseInfo {
                    indexCaseInfo.confirmTest(confirmationDay: npexDay)
                    $0.indexCaseInfo = indexCaseInfo
                }
            case .overwrite:
                $0.indexCaseInfo = IndexCaseInfo(
                    symptomaticInfo: nil,
                    testInfo: IndexCaseInfo.TestInfo(result: testResult, testKitType: testKitType, requiresConfirmatoryTest: requiresConfirmatoryTest, confirmatoryDayLimit: confirmatoryDayLimit, receivedOnDay: receivedOn, testEndDay: npexDay)
                )
            case .updateAndConfirm:
                if let storedIndexCaseInfo = $0.indexCaseInfo {
                    var indexCaseInfo = IndexCaseInfo(
                        symptomaticInfo: storedIndexCaseInfo.symptomaticInfo,
                        testInfo: IndexCaseInfo.TestInfo(result: testResult, testKitType: testKitType, requiresConfirmatoryTest: requiresConfirmatoryTest, confirmatoryDayLimit: confirmatoryDayLimit, receivedOnDay: receivedOn, testEndDay: npexDay)
                    )
                    if let confirmedDay = storedIndexCaseInfo.testInfo?.confirmedOnDay ?? $0.indexCaseInfo?.assumedTestEndDay {
                        indexCaseInfo.confirmTest(confirmationDay: confirmedDay)
                    }
                    $0.indexCaseInfo = indexCaseInfo
                } else {
                    var indexCaseInfo = IndexCaseInfo(
                        symptomaticInfo: nil,
                        testInfo: IndexCaseInfo.TestInfo(result: testResult, testKitType: testKitType, requiresConfirmatoryTest: requiresConfirmatoryTest, confirmatoryDayLimit: confirmatoryDayLimit, receivedOnDay: receivedOn, testEndDay: npexDay)
                    )
                    if let confirmedDay = $0.indexCaseInfo?.testInfo?.confirmedOnDay ?? $0.indexCaseInfo?.assumedTestEndDay {
                        indexCaseInfo.confirmTest(confirmationDay: confirmedDay)
                    }
                    $0.indexCaseInfo = indexCaseInfo
                }
            case .overwriteAndComplete:
                var indexCaseInfo = IndexCaseInfo(
                    symptomaticInfo: nil,
                    testInfo: IndexCaseInfo.TestInfo(result: testResult, testKitType: testKitType, requiresConfirmatoryTest: requiresConfirmatoryTest, confirmatoryDayLimit: confirmatoryDayLimit, receivedOnDay: receivedOn, testEndDay: npexDay)
                )
                
                if let completedOnDay = $0.indexCaseInfo?.testInfo?.completedOnDay ?? $0.indexCaseInfo?.assumedTestEndDay {
                    indexCaseInfo.completeTest(completedOnDay: completedOnDay)
                }
                
                $0.indexCaseInfo = indexCaseInfo
                
            case .overwriteAndConfirm:
                var indexCaseInfo = IndexCaseInfo(
                    symptomaticInfo: nil,
                    testInfo: IndexCaseInfo.TestInfo(result: testResult, testKitType: testKitType, requiresConfirmatoryTest: requiresConfirmatoryTest, confirmatoryDayLimit: confirmatoryDayLimit, receivedOnDay: receivedOn, testEndDay: npexDay)
                )
                if let confirmedDay = $0.indexCaseInfo?.testInfo?.confirmedOnDay ?? $0.indexCaseInfo?.assumedTestEndDay {
                    indexCaseInfo.confirmTest(confirmationDay: confirmedDay)
                }
                $0.indexCaseInfo = indexCaseInfo
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
            $0.hasAcknowledgedStartOfContactIsolation = true
        }
        _ = save(isolationInfo)
    }
    
    func restartIsolationAcknowledgement() {
        let isolationInfo = mutating(self.isolationInfo) {
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
        
        return IsolationLogicalState(today: currentDateProvider.currentLocalDay, info: isolationInfo, configuration: configuration)
    }
    
    func provideExposureDetails() -> (encounterDate: Date,
                                      notificationDate: Date,
                                      optOutOfIsolationDate: Date?)? {
        guard let contactCaseInfo = isolationInfo.contactCaseInfo else {
            return nil
        }
        
        let optOutOfIsolationDate = contactCaseInfo.optOutOfIsolationDay.map {
            LocalDay(gregorianDay: $0, timeZone: .current).startOfDay
        }
        
        return (
            encounterDate: LocalDay(gregorianDay: contactCaseInfo.exposureDay, timeZone: .current).startOfDay,
            notificationDate: LocalDay(gregorianDay: contactCaseInfo.isolationFromStartOfDay, timeZone: .current).startOfDay,
            optOutOfIsolationDate: optOutOfIsolationDate
        )
    }
    
    func provideSymptomsOnsetDate() -> Date? {
        guard let symptomaticInfo = isolationInfo.indexCaseInfo?.symptomaticInfo else {
            return nil
        }
        
        return LocalDay(gregorianDay: symptomaticInfo.assumedOnsetDay, timeZone: .current).startOfDay
    }
    
    func recordMetrics() -> AnyPublisher<Void, Never> {
        if let contactCaseInfo = isolationStateInfo?.isolationInfo.contactCaseInfo {
            Metrics.signpost(.contactCaseBackgroundTick)
            if contactCaseInfo.optOutOfIsolationDay != nil {
                Metrics.signpost(.optedOutForContactIsolationBackgroundTick)
            }
        }
        if let indexCaseInfo = isolationStateInfo?.isolationInfo.indexCaseInfo {
            Metrics.signpost(.indexCaseBackgroundTick)
            if indexCaseInfo.testInfo?.result == .positive {
                if let testKit = indexCaseInfo.testInfo?.testKitType {
                    switch testKit {
                    case .labResult:
                        Metrics.signpost(.testedPositiveBackgroundTick)
                    case .rapidResult:
                        Metrics.signpost(.hasTestedLFDPositiveBackgroundTick)
                    case .rapidSelfReported:
                        Metrics.signpost(.hasTestedSelfRapidPositiveBackgroundTick)
                    }
                } else {
                    Metrics.signpost(.testedPositiveBackgroundTick)
                }
            }
            if indexCaseInfo.symptomaticInfo != nil {
                Metrics.signpost(.selfDiagnosedBackgroundTick)
            }
        }
        
        return Empty().eraseToAnyPublisher()
    }
}
