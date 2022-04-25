//
// Copyright © 2021 DHSC. All rights reserved.
//

import UIKit
import Localization
import SwiftUI

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
                                        title: localize(.covid_guidance_hub_for_england_title),
                                        description: localize(.covid_guidance_hub_for_england_description),
                                        iconName: .externalLink,
                                        action: interactor.didTapGuidanceForCovid19EnglandLink
                                    )
                )
                
                HubButtonCell(viewModel:
                                    .init(
                                        title: localize(.covid_guidance_hub_check_symptoms_title),
                                        description: localize(.covid_guidance_hub_check_symptoms_description),
                                        iconName: .externalLink,
                                        action: interactor.didTapGuidanceForCheckSymptomsEnglandLink
                                    )
                )
                
                HubButtonCell(viewModel:
                                    .init(
                                        title: localize(.covid_guidance_hub_latest_title),
                                        description: localize(.covid_guidance_hub_latest_description),
                                        iconName: .externalLink,
                                        action: interactor.didTapLatestGuidanceCovid19EnglandLink
                                    )
                )
                
                HubButtonCell(viewModel:
                                    .init(
                                        title: localize(.covid_guidance_hub_positive_test_result_title),
                                        description: localize(.covid_guidance_hub_positive_test_result_description),
                                        iconName: .externalLink,
                                        action: interactor.didTapGuidancePositiveCovid19TestResultEnglandLink
                                    )
                )
                
                HubButtonCell(viewModel:
                                    .init(
                                        title: localize(.covid_guidance_hub_travelling_abroad_title),
                                        description: localize(.covid_guidance_hub_travelling_abroad_description),
                                        iconName: .externalLink,
                                        action: interactor.didTapGuidanceTravillingAbroadEnglandLink
                                    )
                )
                
                HubButtonCell(viewModel:
                                    .init(
                                        title: localize(.covid_guidance_hub_check_ssp_title),
                                        description: localize(.covid_guidance_hub_check_ssp_description),
                                        iconName: .externalLink,
                                        action: interactor.didTapGuidanceClaimSSPEnglandLink
                                    )
                )
                
                HubButtonCell(viewModel:
                                    .init(
                                        title: localize(.covid_guidance_hub_covid_enquiries_title),
                                        description: localize(.covid_guidance_hub_covid_enquiries_description),
                                        iconName: .externalLink,
                                        action: interactor.didTapGuidanceGetHelpCovid19EnquiriesEnglandLink
                                    )
                )
                
            }
            
        }
        .padding(.bottom, .bigSpacing)
        .background(Color(.background))
    }
}

public protocol GuidanceHubEnglandViewControllerInteracting {
    func didTapGuidanceForCovid19EnglandLink()
    func didTapGuidanceForCheckSymptomsEnglandLink()
    func didTapLatestGuidanceCovid19EnglandLink()
    func didTapGuidancePositiveCovid19TestResultEnglandLink()
    func didTapGuidanceTravillingAbroadEnglandLink()
    func didTapGuidanceClaimSSPEnglandLink()
    func didTapGuidanceGetHelpCovid19EnquiriesEnglandLink()
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





