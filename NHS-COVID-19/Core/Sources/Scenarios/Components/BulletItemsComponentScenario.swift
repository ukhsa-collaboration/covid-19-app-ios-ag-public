//
// Copyright © 2021 DHSC. All rights reserved.
//

import Integration
import Interface
import SwiftUI

public class BulletItemsComponentScenario: Scenario {

    public static let name = "BulletItems"
    public static let kind = ScenarioKind.component

    static var appController: AppController {
        BasicAppController(rootViewController: UIHostingController(rootView: ContentView()))
    }

}

private struct ContentView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: .doubleSpacing) {
                    Text("Unordered").styleAsHeading()
                    BulletItems(rows: [
                        "Here is a short point for you to consider.",
                        "Here is a longer point that might stretch over multiple lines. Generally we should try and keep sentences to fewer than 20 words.",
                    ])
                    Text("Ordered").styleAsHeading()
                    NumberedBulletItems(rows: [
                        "Eat an apple. Apples are good for you.",
                        "Read a book. Preferably something that makes you feel happy and doesn't make you feel sad.",
                        "Drink some water.",
                        "Give yourself something long and repetitive to do, maybe like writing a long sentence such as this line which exists solely to test text wrapping over multiple lines.",
                    ]) { index, row in
                        "Step \(index): \(row)"
                    }
                }
                .padding(.standardSpacing)
            }
        }
    }

}
