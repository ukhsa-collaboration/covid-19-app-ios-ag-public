//
// Copyright © 2020 NHSX. All rights reserved.
//

import Integration
import SwiftUI

struct CreateExperimentView: View {
    
    @ObservedObject
    var experimentManager: ExperimentManager
    
    @ObservedObject
    var experimentCreator: ExperimentCreator
    
    @State
    var experimentName = ""
    
    var complete: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: .standardSpacing) {
                List {
                    Section {
                        TextInputRow(title: "Team", text: $experimentManager.teamName)
                        TextInputRow(title: "Experiment", text: $experimentName)
                        Toggle("Run detection periodically", isOn: $experimentCreator.isPeriodicDetectionEnabled)
                        if experimentManager.usingEnApiVersion == 1 {
                            Toggle("Detect with multiple configs", isOn: $experimentCreator.isMultiConfigurationEnabled)
                        }
                    }
                }
                .listStyle(GroupedListStyle())
                if experimentCreator.error != nil {
                    Text(verbatim: "\(experimentCreator.error!)")
                        .foregroundColor(Color(.systemRed))
                }
                PrimaryButton(
                    title: experimentCreator.isCreatingExperiment ? "Creating…" : "Create Experiment",
                    action: self.createExperiment
                )
                .disabled(isButtonDisabled)
            }
            .navigationBarTitle("Create new experiment", displayMode: .inline)
        }
    }
    
    private var isButtonDisabled: Bool {
        (
            experimentManager.teamName.isEmpty ||
                experimentName.isEmpty ||
                experimentCreator.isCreatingExperiment
        )
    }
    
    private func createExperiment() {
        experimentCreator.createExperiment(name: experimentName, storeIn: experimentManager, complete: complete)
    }
    
}
