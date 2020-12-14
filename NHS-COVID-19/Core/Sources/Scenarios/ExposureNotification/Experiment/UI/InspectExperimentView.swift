//
// Copyright © 2020 NHSX. All rights reserved.
//

import Integration
import SwiftUI

struct InspectExperimentView: View {
    
    @ObservedObject
    var experimentInspector: ExperimentInspector
    
    @ObservedObject
    var experimentManager: ExperimentManager
    
    var participants: [Experiment.Participant] {
        experimentInspector.experiment?.participants ?? []
    }
    
    var participantsV2: [Experiment.ParticipantV2] {
        experimentInspector.experimentV2?.participants ?? []
    }
    
    var body: some View {
        NavigationView {
            content
                .navigationBarTitle("Experiment \(experimentInspector.experimentName)", displayMode: .inline)
        }
    }
    
    private var content: some View {
        if experimentInspector.isLoading {
            return AnyView(Text("Loading…"))
        } else {
            return AnyView(experimentDetails)
        }
    }
    
    private var experimentDetails: some View {
        List {
            Section(header: Text("Parameters")) {
                AttributeRow(title: "Automatically run detection", value: automaticallyRunDetectionValue)
                AttributeRow(title: "Detection configurations", value: detectionConfigurationsValue)
            }
            Section(header: Text("Lead")) {
                Text(self.getLeadName() ?? "")
            }
            
            if experimentManager.usingEnApiVersion == 2 {
                Section(header: Text("Participants (\(participantsV2.count))")) {
                    ForEach(participantsV2) { participant in
                        AttributeRow(title: participant.deviceName, value: self.getResultsText(results: participant.results))
                    }
                }
            } else {
                Section(header: Text("Participants (\(participants.count))")) {
                    ForEach(participants) { participant in
                        AttributeRow(title: participant.deviceName, value: self.getResultsText(results: participant.results))
                    }
                }
            }

            if experimentInspector.error != nil {
                Section(header: Text("Error")) {
                    Text(verbatim: "\(self.experimentInspector.error!)")
                }
            }
        }
        .listStyle(GroupedListStyle())
    }
    
    private var automaticallyRunDetectionValue: String {
        guard
            let duration = experimentInspector.experiment?.automaticDetectionFrequency,
            duration > 0 else {
            return "Disabled"
        }
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .brief
        return "Every \(formatter.string(from: duration) ?? "")"
    }
    
    private var detectionConfigurationsValue: String {
        "\(experimentInspector.experiment?.requestedConfigurations.count ?? 0)"
    }
    
    private func getLeadName() -> String? {
        if experimentManager.usingEnApiVersion == 2 {
            return experimentInspector.experimentV2?.lead.deviceName
        }
        return experimentInspector.experiment?.lead.deviceName
    }

    private func getResultsText(results: [Any]?) -> String {
        let count = results?.count ?? 0
        switch count {
        case 0:
            return ""
        case 1:
            return "Uploaded 1 result set"
        default:
            return "Uploaded \(count) result sets"
        }
    }
    
}


