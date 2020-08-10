//
// Copyright © 2020 NHSX. All rights reserved.
//

import Integration
import Interface
import SwiftUI
import UIKit

struct SelectRoleView: View {
    
    @ObservedObject
    var experimentManager: ExperimentManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                List {
                    Section {
                        TextInputRow(title: "Device Name", text: $experimentManager.deviceName)
                    }
                }
                .listStyle(GroupedListStyle())
                PrimaryButton(title: "Team Lead") {
                    self.experimentManager.role = .lead
                }
                .disabled(experimentManager.deviceName.isEmpty)
                PrimaryButton(title: "Participant") {
                    self.experimentManager.role = .participant
                }
                .disabled(experimentManager.deviceName.isEmpty)
            }
            .navigationBarTitle("Select Role")
        }
    }
    
}
