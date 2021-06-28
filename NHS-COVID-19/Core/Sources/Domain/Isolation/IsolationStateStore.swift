//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Foundation

public protocol SymptomsOnsetDateAndExposureDetailsProviding {
    func provideSymptomsOnsetDate() -> Date?
    func provideExposureDetails() -> (encounterDate: Date,
                                      notificationDate: Date)?
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
            $0.hasAcknowledgedStartOfIsolation = true
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
        }
        return save(isolationInfo)
    }
    
    func newIsolationStateInfo(from currentIsolationInfo: IsolationInfo?, for unacknowledgedTestResult: UnacknowledgedTestResult, testKitType: TestKitType?, requiresConfirmatoryTest: Bool, confirmatoryDayLimit: Int? = nil, receivedOn: GregorianDay, npexDay: GregorianDay, operation: IsolationStateStore.Operation) -> IsolationStateInfo {
        let testResult = TestResult(unacknowledgedTestResult)
        
        let isolationInfo = mutating(currentIsolationInfo ?? IsolationInfo()) {
            if requiresConfirmatoryTest == false, testResult == .positive, operation != .ignore {
                $0.contactCaseInfo = nil
            }
            
            switch operation {
            case .nothing, .ignore:
                return
            case .deleteSymptoms:
                if var indexCaseInfo = $0.indexCaseInfo {
                    indexCaseInfo = IndexCaseInfo(
                        symptomaticInfo: nil,
                        testInfo: $0.indexCaseInfo?.testInfo
                    )
                    $0.indexCaseInfo = indexCaseInfo
                }
            case .deleteTest:
                if var indexCaseInfo = $0.indexCaseInfo {
                    indexCaseInfo = IndexCaseInfo(
                        symptomaticInfo: $0.indexCaseInfo?.symptomaticInfo,
                        testInfo: nil
                    )
                    $0.indexCaseInfo = indexCaseInfo
                }
            case .update:
                if var indexCaseInfo = $0.indexCaseInfo {
                    indexCaseInfo.set(testResult: testResult, testKitType: testKitType, requiresConfirmatoryTest: requiresConfirmatoryTest, confirmatoryDayLimit: confirmatoryDayLimit, receivedOn: receivedOn, testEndDay: npexDay)
                    $0.indexCaseInfo = indexCaseInfo
                } else {
                    $0.indexCaseInfo = IndexCaseInfo(
                        symptomaticInfo: nil,
                        testInfo: IndexCaseInfo.TestInfo(result: testResult, testKitType: testKitType, requiresConfirmatoryTest: requiresConfirmatoryTest, confirmatoryDayLimit: confirmatoryDayLimit, receivedOnDay: receivedOn, testEndDay: npexDay)
                    )
                }
            case .complete:
                if var indexCaseInfo = $0.indexCaseInfo {
                    indexCaseInfo.completeTest(completedOnDay: npexDay)
                    $0.indexCaseInfo = indexCaseInfo
                }
            case .completeAndDeleteSymptoms:
                if var indexCaseInfo = $0.indexCaseInfo {
                    indexCaseInfo = IndexCaseInfo(
                        symptomaticInfo: nil,
                        testInfo: $0.indexCaseInfo?.testInfo
                    )
                    indexCaseInfo.completeTest(completedOnDay: npexDay)
                    $0.indexCaseInfo = indexCaseInfo
                }
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
                    var indexCaseInfo = storedIndexCaseInfo
                    indexCaseInfo.set(testResult: testResult, testKitType: testKitType, requiresConfirmatoryTest: requiresConfirmatoryTest, confirmatoryDayLimit: confirmatoryDayLimit, receivedOn: receivedOn, testEndDay: npexDay)
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
        
        return IsolationLogicalState(today: currentDateProvider.currentLocalDay, info: isolationInfo, configuration: configuration)
    }
    
    func provideExposureDetails() -> (encounterDate: Date,
                                      notificationDate: Date)? {
        guard let encounterDay = isolationInfo.contactCaseInfo?.exposureDay,
            let notificationDay = isolationInfo.contactCaseInfo?.isolationFromStartOfDay else {
            return nil
        }
        return (
            encounterDate: LocalDay(gregorianDay: encounterDay, timeZone: .current).startOfDay,
            notificationDate: LocalDay(gregorianDay: notificationDay, timeZone: .current).startOfDay
        )
    }
    
    func provideSymptomsOnsetDate() -> Date? {
        guard let symptomaticInfo = isolationInfo.indexCaseInfo?.symptomaticInfo else {
            return nil
        }
        
        return LocalDay(gregorianDay: symptomaticInfo.assumedOnsetDay, timeZone: .current).startOfDay
    }
    
    func recordMetrics() -> AnyPublisher<Void, Never> {
        if isolationStateInfo?.isolationInfo.contactCaseInfo != nil {
            Metrics.signpost(.contactCaseBackgroundTick)
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
