//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation
import Common

public enum Feature: CaseIterable {

    /// Puts a button on the home screen that allows people to see the local COVID statistics
    /// for their area and for the whole country.
    case localStatistics

    /// Allows people to check in to venues by scanning QR codes.
    /// Does NOT stop people from seeing the venues they've previously checked in to, or receiving
    /// risky venue alerts for those.
    case venueCheckIn

    /// Shows contact cases in England a questionnaire to determine if they need to isolate or not.
    case contactOptOutFlowEngland

    /// Shows contact cases in Wales a questionnaire to determine if they need to isolate or not.
    case contactOptOutFlowWales

    /// Allows people to find out about the different types of COVID-19 tests and how to get tested.
    /// It's also possible to enter test results in form of a 8 character code received.
    case testingForCOVID19

    /// Shows a button leading to the Self-Isolation Hub for people in England who are in isolation.
    case selfIsolationHubEngland

    /// Shows a button leading to the Self-Isolation Hub for people in Wales who are in isolation.
    case selfIsolationHubWales

    /// Shows a button leading to the Guidance Hub for people in England.
    case guidanceHubEngland

    /// Shows a button leading to the Guidance Hub for people in Wales.
    case guidanceHubWales

    /// Enables self reporting flow, where people can report private test results
    case selfReporting

    /// Enables the closure screen for decommissioning
    case decommissioningClosureSceen

    public static let productionEnabledFeatures: [Feature] = [
        .guidanceHubEngland,
        .guidanceHubWales,
        .selfReporting,
        .decommissioningClosureSceen
    ]
}

extension Feature {
    var associatedMetrics: [Metric] {
        switch self {
        case .decommissioningClosureSceen:
            return []
        case .localStatistics:
            return []
        case .venueCheckIn:
            return [
                .receivedRiskyVenueM2Warning,
                .hasReceivedRiskyVenueM2WarningBackgroundTick,
                .didAccessRiskyVenueM2Notification,
                .selectedTakeTestM2Journey,
                .selectedTakeTestLaterM2Journey,
                .selectedHasSymptomsM2Journey,
                .selectedHasNoSymptomsM2Journey,
                .selectedLFDTestOrderingM2Journey,
                .selectedHasLFDTestM2Journey,
                .receivedRiskyVenueM1Warning,
            ]
        case .contactOptOutFlowEngland:
            return [
                .acknowledgedStartOfIsolationDueToRiskyContact,
                .isolatedForHadRiskyContactBackgroundTick,
            ]
        case .contactOptOutFlowWales:
            return [
                .acknowledgedStartOfIsolationDueToRiskyContact,
                .isolatedForHadRiskyContactBackgroundTick,
            ]
        case .testingForCOVID19:
            return []
        case .selfIsolationHubEngland:
            return [
                .didAccessSelfIsolationNoteLink,
                .receivedActiveIpcToken,
                .haveActiveIpcTokenBackgroundTick,
                .selectedIsolationPaymentsButton,
                .launchedIsolationPaymentsApplication,
            ]
        case .selfIsolationHubWales:
            return [
                .didAccessSelfIsolationNoteLink,
                .receivedActiveIpcToken,
                .haveActiveIpcTokenBackgroundTick,
                .selectedIsolationPaymentsButton,
                .launchedIsolationPaymentsApplication,
            ]
        case .guidanceHubEngland:
            return []
        case .guidanceHubWales:
            return []
        case .selfReporting:
            return [
                .selfReportedVoidSelfLFDTestResultEnteredManually,
                .selfReportedNegativeSelfLFDTestResultEnteredManually,
                .isPositiveSelfLFDFree,
                .selfReportedPositiveSelfLFDOnGov,
                .completedSelfReportingTestFlow,
            ]
        }
    }

    var countriesOfRelevance: [Country] {
        switch self {
        case .decommissioningClosureSceen:
            return [.england, .wales]
        case .localStatistics:
            return [.england, .wales]
        case .venueCheckIn:
            return [.england, .wales]
        case .contactOptOutFlowEngland:
            return [.england]
        case .contactOptOutFlowWales:
            return [.wales]
        case .testingForCOVID19:
            return [.england, .wales]
        case .selfIsolationHubEngland:
            return [.england]
        case .selfIsolationHubWales:
            return [.wales]
        case .guidanceHubEngland:
            return [.england]
        case .guidanceHubWales:
            return [.wales]
        case .selfReporting:
            return [.england, .wales]
        }
    }
}
