//
// Copyright © 2020 NHSX. All rights reserved.
//

import Integration
import Interface
import SwiftUI
import UIKit

struct LeadHomeView: View {
    
    enum Sheet: Identifiable {
        case createExperiment(ExperimentCreator)
        case inspectExperiment(ExperimentInspector)
        
        var id: ObjectIdentifier {
            switch self {
            case .createExperiment(let object):
                return object.id
            case .inspectExperiment(let object):
                return object.id
            }
        }
        
        var experimentCreator: ExperimentCreator? {
            guard case .createExperiment(let object) = self else {
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
                .disabled(experimentManager.experimentName.isEmpty)
                PrimaryButton(title: "Create new experiment") {
                    self.sheet = .createExperiment(ExperimentCreator())
                }
            }
            .padding(.standardSpacing)
            .navigationBarTitle("Lead (\(experimentManager.deviceName))")
        }
        .sheet(item: $sheet) { sheet -> AnyView in
            if sheet.experimentCreator != nil {
                return AnyView(
                    CreateExperimentView(
                        experimentManager: self.experimentManager,
                        experimentCreator: sheet.experimentCreator!
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
            return "No experiments in progress"
        } else {
            return "Experiment: \(experimentManager.experimentName)"
        }
    }
    
}
