//
// Copyright © 2021 DHSC. All rights reserved.
//

import UIKit
import Localization
import SwiftUI

private struct GuidanceHubWalesView: View {

    private let interactor: GuidanceHubWalesViewController.Interacting

    init(interactor: GuidanceHubWalesViewController.Interacting) {
        self.interactor = interactor
    }

    var body: some View {
        ScrollView {
            VStack(spacing: .halfHairSpacing) {
                HubButtonCell(viewModel:
                                    .init(
                                        title: localize(.covid_guidance_hub_wales_button_one_title),
                                        description: localize(.covid_guidance_hub_wales_button_one_description),
                                        iconName: .externalLink,
                                        action: interactor.didTapLink1
                                    )
                )

                HubButtonCell(viewModel:
                                    .init(
                                        title: localize(.covid_guidance_hub_wales_button_two_title),
                                        description: localize(.covid_guidance_hub_wales_button_two_description),
                                        iconName: .externalLink,
                                        action: interactor.didTapLink2
                                    )
                )
                HubButtonCell(viewModel:
                                    .init(
                                        title: localize(.covid_guidance_hub_wales_button_three_title),
                                        description: localize(.covid_guidance_hub_wales_button_three_description),
                                        iconName: .externalLink,
                                        action: interactor.didTapLink3
                                    )
                )
                HubButtonCell(viewModel:
                                    .init(
                                        title: localize(.covid_guidance_hub_wales_button_four_title),
                                        description: localize(.covid_guidance_hub_wales_button_four_description),
                                        iconName: .externalLink,
                                        action: interactor.didTapLink4
                                    )
                )
                HubButtonCell(viewModel:
                                    .init(
                                        title: localize(.covid_guidance_hub_wales_button_five_title),
                                        description: localize(.covid_guidance_hub_wales_button_five_description),
                                        iconName: .externalLink,
                                        action: interactor.didTapLink5
                                    )
                )
                HubButtonCell(viewModel:
                                    .init(
                                        title: localize(.covid_guidance_hub_wales_button_six_title),
                                        description: localize(.covid_guidance_hub_wales_button_six_description),
                                        iconName: .externalLink,
                                        action: interactor.didTapLink6
                                    )
                )
                HubButtonCell(viewModel:
                                    .init(
                                        title: localize(.covid_guidance_hub_wales_button_seven_title),
                                        description: localize(.covid_guidance_hub_wales_button_seven_description),
                                        iconName: .externalLink,
                                        action: interactor.didTapLink7
                                    )
                )

            }

        }
        .padding(.bottom, .bigSpacing)
        .background(Color(.background))
    }
}

public protocol GuidanceHubWalesViewControllerInteracting {
    func didTapLink1()
    func didTapLink2()
    func didTapLink3()
    func didTapLink4()
    func didTapLink5()
    func didTapLink6()
    func didTapLink7()
}

public class GuidanceHubWalesViewController: RootViewController {

    public typealias Interacting = GuidanceHubWalesViewControllerInteracting

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

        let GuidanceHubWalesView = GuidanceHubWalesView(interactor: interactor)
            .edgesIgnoringSafeArea(.bottom)

        let contentViewController = UIHostingController(rootView: GuidanceHubWalesView)
        addFilling(contentViewController)

    }

}
