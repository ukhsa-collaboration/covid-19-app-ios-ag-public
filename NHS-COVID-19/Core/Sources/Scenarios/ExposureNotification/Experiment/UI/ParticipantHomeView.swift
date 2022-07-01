//
// Copyright © 2020 NHSX. All rights reserved.
//

import Integration
import Interface
import SwiftUI
import UIKit

struct ParticipantHomeView: View {

    enum Sheet: Identifiable {
        case joinExperiment(ExperimentJoiner)
        case inspectExperiment(ExperimentInspector)

        var id: ObjectIdentifier {
            switch self {
            case .joinExperiment(let object):
                return object.id
            case .inspectExperiment(let object):
                return object.id
            }
        }

        var experimentJoiner: ExperimentJoiner? {
            guard case .joinExperiment(let object) = self else {
                return nil
            }
            return object
        }

        var experimentInspector: ExperimentInspector? {
            guard case .inspectExperiment(let object) = self else {
                return nil
            }
            return object
        }
    }

    @ObservedObject
    var experimentManager: ExperimentManager

    @State
    var sheet: Sheet?

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Text(experimentNameTitle)
                Text("Using EN API version: \(experimentManager.usingEnApiVersion)")
                PrimaryButton(title: "View current experiment") {
                    self.sheet = .inspectExperiment(ExperimentInspector(manager: self.experimentManager))
                }
                .disabled(experimentManager.experimentName.isEmpty || experimentManager.isProcessingResults)
                PrimaryButton(title: processingTitle) {
                    self.startProcessing()
                }
                .disabled(processingButtonDisabled)
                PrimaryButton(title: "Join an experiment") {
                    self.sheet = .joinExperiment(ExperimentJoiner())
                }
                .disabled(experimentManager.isProcessingResults)
            }
            .padding(.standardSpacing)
            .navigationBarTitle("Participant (\(experimentManager.deviceName))")
        }
        .sheet(item: $sheet) { sheet -> AnyView in
            if sheet.experimentJoiner != nil {
                return AnyView(
                    JoinExperimentView(
                        experimentManager: self.experimentManager,
                        experimentJoiner: sheet.experimentJoiner!
                    ) {
                        self.sheet = nil
                    }
                )
            } else {
                return AnyView(
                    InspectExperimentView(
                        experimentInspector: sheet.experimentInspector!,
                        experimentManager: self.experimentManager
                    )
                )
            }
        }
    }

    private var experimentNameTitle: String {
        if experimentManager.experimentName.isEmpty {
            return "Not part of any experiments."
        } else if let processingError = experimentManager.processingError {
            return """
            Experiment: \(experimentManager.experimentName).
            Processing error: \(processingError)
            """
        } else {
            return "Experiment: \(experimentManager.experimentName)"
        }
    }

    private var processingButtonDisabled: Bool {
        guard !experimentManager.experimentName.isEmpty else { return true }
        if experimentManager.automaticDetectionFrequency > 0 {
            return false
        } else {
            return experimentManager.isProcessingResults
        }
    }

    private var processingTitle: String {
        if experimentManager.automaticDetectionFrequency > 0 {
            if experimentManager.isProcessingResults {
                return "End detection"
            } else {
                return "Start periodic detection"
            }
        } else {
            return experimentManager.isProcessingResults ? "Processing…" : "Process experiment results"
        }
    }

    private func startProcessing() {
        if experimentManager.automaticDetectionFrequency > 0 {
            if experimentManager.isProcessingResults {
                return experimentManager.endAutomaticDetection()
            } else {
                if #available(iOS 13.7, *), experimentManager.usingEnApiVersion == 2 {
                    return experimentManager.startAutomaticDetectionV2()
                }
                return experimentManager.startAutomaticDetection()
            }
        } else {
            if #available(iOS 13.7, *), experimentManager.usingEnApiVersion == 2 {
                experimentManager.processResultsV2()
            } else {
                // Fallback on earlier versions
                experimentManager.processResults()
            }
        }
    }

}
