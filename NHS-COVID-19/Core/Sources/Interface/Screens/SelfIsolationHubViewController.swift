//
// Copyright © 2021 DHSC. All rights reserved.
//

import Localization
import SwiftUI

private struct SelfIsolationHubView: View {
    
    private let interactor: SelfIsolationHubViewController.Interacting
    @ObservedObject private var showOrderTestButton: InterfaceProperty<Bool>
    @ObservedObject private var showFinancialSupportButton: InterfaceProperty<Bool>
    
    init(
        interactor: SelfIsolationHubViewController.Interacting,
        showOrderTestButton: InterfaceProperty<Bool>,
        showFinancialSupportButton: InterfaceProperty<Bool>
    ) {
        self.interactor = interactor
        self.showOrderTestButton = showOrderTestButton
        self.showFinancialSupportButton = showFinancialSupportButton
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: .halfHairSpacing) {
                if showOrderTestButton.wrappedValue {
                    HubButtonCell(viewModel:
                        .init(
                            title: localize(.self_isolation_hub_book_a_test_title),
                            description: localize(.self_isolation_hub_book_a_test_description),
                            action: interactor.didTapBookFreeTestButton
                        )
                    )
                }
                if showFinancialSupportButton.wrappedValue {
                    HubButtonCell(viewModel:
                        .init(
                            title: localize(.self_isolation_hub_financial_support_title),
                            description: localize(.self_isolation_hub_financial_support_description),
                            action: interactor.didTapCheckIfEligibleForFinancialSupport
                        )
                    )
                }
                HubButtonCell(viewModel:
                    .init(
                        title: localize(.self_isolation_hub_get_isolation_note_title),
                        description: localize(.self_isolation_hub_get_isolation_note_description),
                        iconName: .externalLink,
                        action: interactor.didTapGetIsolationNoteLink
                    ))
            }
            
            accordionGroups
                .padding(.standardSpacing)
        }
        .padding(.bottom, .bigSpacing)
        .background(Color(.background))
    }
    
    private var accordionGroups: some View {
        VStack(alignment: .leading, spacing: .doubleSpacing) {
            // Advice and support
            AccordionGroup(localize(.self_isolation_hub_accordion_group_advice_and_support_heading)) {
                AccordionView(localize(.self_isolation_hub_accordion_how_to_title)) {
                    ForEach.fromStrings(localizeAndSplit(.self_isolation_hub_accordion_how_to_top_text_1), spacing: .standardSpacing) {
                        Text($0).styleAsBody()
                    }
                    BulletItems(rows: localizeAndSplit(.self_isolation_hub_accordion_how_to_bullet_points_1))
                    ForEach.fromStrings(localizeAndSplit(.self_isolation_hub_accordion_how_to_top_text_2), spacing: .standardSpacing) {
                        Text($0).styleAsBody()
                    }
                    BulletItems(rows: localizeAndSplit(.self_isolation_hub_accordion_how_to_bullet_points_2))
                    Text(localize(.self_isolation_hub_accordion_how_to_looking_more_advice)).styleAsSecondaryHeading()
                    ExternalLinkButton(
                        localize(.self_isolation_hub_read_gov_guidance_link_title),
                        action: interactor.didTapReadGovernmentGuidanceLink
                    )
                    ExternalLinkButton(
                        localize(.self_isolation_hub_find_your_la_link_title),
                        action: interactor.didTapFindYourLocalAuthorityLink
                    )
                }
                
                AccordionView(localize(.self_isolation_hub_accordion_practical_support_title)) {
                    ForEach.fromStrings(localizeAndSplit(.self_isolation_hub_accordion_practical_support_top_text), spacing: .standardSpacing) {
                        Text($0).styleAsBody()
                    }
                    BulletItems(rows: localizeAndSplit(.self_isolation_hub_accordion_practical_support_bullet_points))
                    ForEach.fromStrings(localizeAndSplit(.self_isolation_hub_accordion_practical_support_bottom_text), spacing: .standardSpacing) {
                        Text($0).styleAsBody()
                    }
                    ExternalLinkButton(
                        localize(.self_isolation_hub_find_your_la_link_title),
                        action: interactor.didTapFindYourLocalAuthorityLink
                    )
                }
            }
        }
    }
    
}

public protocol SelfIsolationHubViewControllerInteracting {
    func didTapBookFreeTestButton()
    func didTapCheckIfEligibleForFinancialSupport()
    func didTapReadGovernmentGuidanceLink()
    func didTapFindYourLocalAuthorityLink()
    func didTapGetIsolationNoteLink()
}

public class SelfIsolationHubViewController: RootViewController {
    
    public typealias Interacting = SelfIsolationHubViewControllerInteracting
    
    private let interactor: Interacting
    private let showOrderTestButton: InterfaceProperty<Bool>
    private let showFinancialSupportButton: InterfaceProperty<Bool>
    
    public init(
        interactor: Interacting,
        showOrderTestButton: InterfaceProperty<Bool>,
        showFinancialSupportButton: InterfaceProperty<Bool>
    ) {
        self.interactor = interactor
        self.showOrderTestButton = showOrderTestButton
        self.showFinancialSupportButton = showFinancialSupportButton
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        title = localize(.self_isolation_hub_title)
        
        let selfIsolationHubView = SelfIsolationHubView(
            interactor: interactor,
            showOrderTestButton: showOrderTestButton,
            showFinancialSupportButton: showFinancialSupportButton
        )
        .edgesIgnoringSafeArea(.bottom)
        
        let contentViewController = UIHostingController(rootView: selfIsolationHubView)
        addFilling(contentViewController)
    }
    
}
