//
// Copyright © 2020 NHSX. All rights reserved.
//

import Integration
import SwiftUI

struct InspectExperimentResultsView: View {

    @ObservedObject
    var experimentInspector: ExperimentInspector

    var participants: [Experiment.Participant] {
        experimentInspector.experiment?.participants ?? []
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
            Section(header: Text("Participants (\(participants.count))")) {
                ForEach(participants) { participant in
                    AttributeRow(title: participant.deviceName, value: participant.resultsText)
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

}

extension Experiment {

    var detections: [(device: String, counterpart: String, value: Int)] {
        participants.flatMap { $0.detections }
    }

}

extension Experiment.Participant {

    fileprivate var resultsText: String {
        guard let result = latestResults else {
            return "No results"
        }
        let count = result.counterparts.lazy
            .filter { !$0.exposureInfos.isEmpty }
            .count
        switch count {
        case 1:
            return "Detected 1 phone"
        default:
            return "Detected \(count) phones"
        }
    }

    var detections: [(device: String, counterpart: String, value: Int)] {
        guard let result = latestResults else { return [] }
        return result.counterparts.compactMap { counterpart in
            guard let info = counterpart.exposureInfos.first else {
                return nil
            }
            return (deviceName, counterpart.deviceName, info.attenuationValue)
        }
    }

    var latestResults: Experiment.DetectionResults? {
        results?.max {
            $0.timestamp < $1.timestamp
        }
    }

}
