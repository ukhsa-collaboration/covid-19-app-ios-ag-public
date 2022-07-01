//
// Copyright © 2020 NHSX. All rights reserved.
//

import Integration
import SwiftUI

struct JoinExperimentView: View {

    @ObservedObject
    var experimentManager: ExperimentManager

    @ObservedObject
    var experimentJoiner: ExperimentJoiner

    var complete: () -> Void

    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section {
                        TextInputRow(title: "Team", text: $experimentManager.teamName)
                    }
                }
                .listStyle(GroupedListStyle())
                if experimentJoiner.error != nil {
                    Text(verbatim: "\(experimentJoiner.error!)")
                        .foregroundColor(Color(.systemRed))
                }
                PrimaryButton(
                    title: experimentJoiner.isCreatingExperiment ? "Joining…" : "Join Experiment",
                    action: self.joinExperiment
                )
                .disabled(experimentManager.teamName.isEmpty || experimentJoiner.isCreatingExperiment)
            }
            .navigationBarTitle("Join new experiment", displayMode: .inline)
        }
    }

    private func joinExperiment() {
        experimentJoiner.joinExperiment(storeIn: experimentManager, complete: complete)
    }

}
