//
// Copyright © 2020 NHSX. All rights reserved.
//

import Integration
import SwiftUI

struct SelectExperimentView: View {
    
    enum Sheet: Identifiable {
        case inspectExperiment(ExperimentInspector)
        case inspectExperimentResults(ExperimentInspector)
        
        var id: ObjectIdentifier {
            switch self {
            case .inspectExperiment(let object), .inspectExperimentResults(let object):
                return object.id
            }
        }
        
        var experimentInspector: ExperimentInspector {
            switch self {
            case .inspectExperiment(let object), .inspectExperimentResults(let object):
                return object
            }
        }
    }
    
    @ObservedObject
    var experimentManager: ExperimentManager
    
    @State
    var sheet: Sheet?
    
    var body: some View {
        NavigationView {
            VStack(spacing: .standardSpacing) {
                List {
                    Section {
                        TextInputRow(title: "Team", text: $experimentManager.teamName)
                        TextInputRow(title: "Experiment ID", text: $experimentManager.experimentId)
                    }
                }
                .listStyle(GroupedListStyle())
                PrimaryButton(
                    title: "View current experiment",
                    action: self.inspectExperiment
                )
                PrimaryButton(
                    title: "View experiment results",
                    action: self.inspectExperimentResults
                )
            }
            .navigationBarTitle("Inspect Experiment", displayMode: .inline)
        }
        .sheet(item: $sheet) { sheet -> AnyView in
            if case .inspectExperimentResults = sheet {
                return AnyView(
                    InspectExperimentResultsView(
                        experimentInspector: sheet.experimentInspector
                    )
                )
            } else {
                return AnyView(
                    InspectExperimentView(
                        experimentInspector: sheet.experimentInspector
                    )
                )
            }
        }
        
    }
    
    private var isButtonDisabled: Bool {
        (
            experimentManager.teamName.isEmpty ||
                experimentManager.experimentId.isEmpty
        )
    }
    
    private func inspectExperiment() {
        sheet = .inspectExperiment(ExperimentInspector(manager: experimentManager))
    }
    
    private func inspectExperimentResults() {
        sheet = .inspectExperimentResults(ExperimentInspector(manager: experimentManager))
    }
    
}
