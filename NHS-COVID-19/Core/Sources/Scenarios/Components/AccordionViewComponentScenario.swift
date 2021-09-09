//
// Copyright © 2021 DHSC. All rights reserved.
//

import Integration
import Interface
import SwiftUI

public class AccordionViewComponentScenario: Scenario {
    
    public static let name = "AccordionView"
    public static let kind = ScenarioKind.component
    
    static var appController: AppController {
        BasicAppController(rootViewController: UIHostingController(rootView: ContentView()))
    }
    
}

private struct ContentView: View {
    
    @State private var preferredColourScheme: ColorScheme = .light
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: .doubleSpacing) {
                    AccordionGroup("Advice and support") {
                        AccordionView("Which results can I enter in the app?") {
                            Text("You are able to enter a positive or negative lab result. Or, if you had an assisted rapid test, you are also able to enter this.")
                            Text("You’ll know which result to enter as it will be 8 characters long and you would have received it via email or text message.")
                        }
                        AccordionView("Why should I enter my test result?") {
                            VStack(alignment: .leading, spacing: .standardSpacing) {
                                Text("If your test is positive, you need to enter it into the app and share your random IDs so that the app can notify other people that you have been near. This helps to break the chain of transmission and stops the spread of COVID-19.")
                                Text("If the test is negative, it’s important to continue to self-isolate as you may become infectious at a later date.")
                            }
                        }
                        AccordionView("Help with everyday tasks from an NHS volunteer") {
                            Text("NHS Volunteer Responders can help with things like:")
                            BulletItems(rows: ["collecting shopping", "collecting medicines and prescriptions", "phone calls if you want to chat to someone"])
                            Text("Call 0808 196 3646 (8am to 8pm, everyday) to arrange help from a volunteer.")
                        }
                        AccordionView("Guidance for households with possible COVID-19 infections. Two lines.") {
                            Text("Some sort of short version of the content here\nhttps://www.gov.uk/government/publications/covid-19-stay-at-home-guidance/stay-at-home-guidance-for-households-with-possible-coronavirus-covid-19-infection ")
                        }
                    }
                    
                    AccordionGroup("How your isolation period is calculated") {
                        AccordionView("You have reported symptoms in the app") {
                            Text("The self-isolation period is the date your symptoms started (symptom onset date) plus 10 full days.")
                            Text("When you enter symptoms in the app it will ask you for the symptom onset date.")
                            Text("If you said that you cannot remember when your symptoms started, the app will calculate your ‘symptom onset date’ as 2 days before you reported symptoms into the app.")
                        }
                        AccordionView("Accordion text") {
                            Text("The first line")
                            Text("The Second line")
                        }
                    }
                    AccordionGroup("Example with chevron") {
                        AccordionView(
                            "How we calculate your isolation period",
                            displayMode: .singleWithChevron
                        ) {
                            Text("Sample text")
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
            .navigationBarTitle("AccordionView")
            .navigationBarItems(trailing: toggleColorSchemeBarItem)
        }
        .environment(\.colorScheme, preferredColourScheme)
    }
    
    private var toggleColorSchemeBarItem: some View {
        Button(
            action: { preferredColourScheme.toggle() },
            label: { Image(systemName: "moon.circle") }
        )
    }
}

// MARK: - Private extensions

private extension ColorScheme {
    
    mutating func toggle() {
        switch self {
        case .dark:
            self = .light
        default:
            self = .dark
        }
    }
    
}
