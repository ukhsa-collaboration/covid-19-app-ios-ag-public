//
// Copyright © 2021 DHSC. All rights reserved.
//

import UIKit
import Localization
import SwiftUI
import Common

private struct GuidanceHubEnglandView: View {

    private let interactor: GuidanceHubEnglandViewController.Interacting

    init(interactor: GuidanceHubEnglandViewController.Interacting) {
        self.interactor = interactor
    }

    var body: some View {
        ScrollView {
            VStack(spacing: .halfHairSpacing) {
                HubButtonCell(viewModel:
                                    .init(
                                        title: localize(.covid_guidance_hub_england_button_one_title),
                                        description: localize(.covid_guidance_hub_england_button_one_description),
                                        iconName: .externalLink,
                                        action: interactor.didTapEnglandLink1
                                    )
                )

                HubButtonCell(viewModel:
                                    .init(
                                        title: localize(.covid_guidance_hub_england_button_two_title),
                                        description: localize(.covid_guidance_hub_england_button_two_description),
                                        iconName: .externalLink,
                                        action: interactor.didTapEnlgandLink2
                                    )
                )

                HubButtonCell(viewModel:
                                    .init(
                                        title: localize(.covid_guidance_hub_england_button_three_title),
                                        description: localize(.covid_guidance_hub_england_button_three_description),
                                        iconName: .externalLink,
                                        action: interactor.didTapEnglandLink3
                                    )
                )

                HubButtonCell(viewModel:
                                    .init(
                                        title: localize(.covid_guidance_hub_england_button_four_title),
                                        description: localize(.covid_guidance_hub_england_button_four_description),
                                        iconName: .externalLink,
                                        action: interactor.didTapEnglandLink4
                                    )
                )

                HubButtonCell(viewModel:
                                    .init(
                                        title: localize(.covid_guidance_hub_england_button_five_title),
                                        description: localize(.covid_guidance_hub_england_button_five_description),
                                        iconName: .externalLink,
                                        action: interactor.didTapEnglandLink5
                                    )
                )

                HubButtonCell(viewModel:
                                    .init(
                                        title: localize(.covid_guidance_hub_england_button_six_title),
                                        description: localize(.covid_guidance_hub_england_button_six_description),
                                        iconName: .externalLink,
                                        action: interactor.didTapEnglandLink6
                                    )
                )

                HubButtonCell(viewModel:
                                    .init(
                                        title: localize(.covid_guidance_hub_england_button_seven_title),
                                        description: localize(.covid_guidance_hub_england_button_seven_description),
                                        iconName: .externalLink,
                                        action: interactor.didTapEnglandLink7,
                                        accessibilityLabel: localize(.covid_guidance_hub_england_button_seven_new_label_accessibility_text)

                                    ),
                              shouldShowNewLabelState: interactor.newLabelForLongCovidEnglandState
                )

                HubButtonCell(viewModel:
                                    .init(
                                        title: localize(.covid_guidance_hub_england_button_eight_title),
                                        description: localize(.covid_guidance_hub_england_button_eight_description),
                                        iconName: .externalLink,
                                        action: interactor.didTapEnglandLink8
                                    )
                )

            }

        }
        .padding(.bottom, .bigSpacing)
        .background(Color(.background))
    }
}

public protocol GuidanceHubEnglandViewControllerInteracting {
    func didTapEnglandLink1()
    func didTapEnlgandLink2()
    func didTapEnglandLink3()
    func didTapEnglandLink4()
    func didTapEnglandLink5()
    func didTapEnglandLink6()
    func didTapEnglandLink7()
    func didTapEnglandLink8()

    var newLabelForLongCovidEnglandState: NewLabelState { get }
}

public class GuidanceHubEnglandViewController: RootViewController {

    public typealias Interacting = GuidanceHubEnglandViewControllerInteracting

    private  let interactor: Interacting

    public init(interactor: Interacting) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
        title = localize(.home_covid19_guidance_button_title)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        let guidanceHubEnglandView = GuidanceHubEnglandView(interactor: interactor)
            .edgesIgnoringSafeArea(.bottom)

        let contentViewController = UIHostingController(rootView: guidanceHubEnglandView)
        addFilling(contentViewController)

    }

}
