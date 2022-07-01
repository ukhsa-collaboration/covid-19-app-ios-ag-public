//
// Copyright © 2021 DHSC. All rights reserved.
//

import Integration
import Interface
import SwiftUI

public class BoxScenario: Scenario {

    public static let name = "Box"
    public static let kind = ScenarioKind.component

    static var appController: AppController {
        let navigation = UINavigationController()
        let hostingVC = UIHostingController(rootView: BoxViewScenario())

        navigation.pushViewController(hostingVC, animated: false)
        return BasicAppController(rootViewController: navigation)
    }
}

private struct BoxViewScenario: View {
    var body: some View {
        VStack {
            Spacer()
            Box {
                HStack {
                    Text("Your age")
                    Spacer()
                    Button(action: {}, label: {
                        Text("Change")
                            .underline()
                    })
                }
                Divider()
                VStack(alignment: .leading) {
                    Text("Were you aged 18 or over on 16 February 2021?")
                    HStack {
                        Image(.checkIcon)
                        Text("Yes")
                    }
                }

            }
            Spacer()
        }
        .padding()
        .background(Color(.background))
    }
}
