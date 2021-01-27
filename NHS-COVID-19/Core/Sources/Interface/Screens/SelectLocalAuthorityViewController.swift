//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import SwiftUI
import UIKit

// MODEL
public struct LocalAuthority: Equatable, Identifiable {
    
    // MARK: - Properties
    
    public var id: UUID
    public var name: String
    
    // MARK: - Init
    
    public init(id: UUID, name: String) {
        self.id = id
        self.name = name
    }
}

struct LocalAuthorities: View {
    @State var selectedAuthority: LocalAuthority? = nil
    
    var localAuthorities: [LocalAuthority]
    var selectAuthority: (LocalAuthority) -> Void
    
    var body: some View {
        VStack(alignment: .center, spacing: .halfSpacing) {
            ForEach(localAuthorities.sorted(by: { $0.name.lowercased() < $1.name.lowercased() })) { la in
                LocalAuthorityCard(
                    viewModel: la,
                    selectedLocalAuthority: $selectedAuthority,
                    selectLocalAuthority: selectAuthority
                )
            }
        }
    }
}

// VIEWMODEL
public class LocalAuthorityViewModel {
    
    // MARK: - Properties
    
    let localAuthorities: [LocalAuthority]
    var postcode: String
    
    // MARK: - Init
    
    public init(postcode: String, localAuthorities: [LocalAuthority]) {
        self.postcode = postcode
        self.localAuthorities = localAuthorities
    }
    
}

public enum LocalAuthoritySelectionError: Error {
    case emptySelection
    case unsupportedCountry
}

public protocol SelectLocalAuthorityViewControllerInteracting {
    func didTapSubmitButton(localAuthority: LocalAuthority?) -> Result<Void, LocalAuthoritySelectionError>
    func didTapLink()
    func dismiss()
}

struct SelectLocalAuthorityContent {
    public typealias Interacting = SelectLocalAuthorityViewControllerInteracting
    
    var views: [StackViewContentProvider]
    
    init(interactor: Interacting, localAuthorityViewModel: LocalAuthorityViewModel) {
        let emptyError = UIHostingController(
            rootView: ErrorBox(
                localize(.local_authority_error_title),
                description: localize(.local_authority_error_description)
            )
        )
        emptyError.view.backgroundColor = .clear
        emptyError.view.isHidden(true)
        
        let unsupportedCountryError = UIHostingController(
            rootView: ErrorBox(
                localize(.local_authority_unsupported_country_error_title),
                description: localize(.local_authority_unsupported_country_error_description)
            )
        )
        unsupportedCountryError.view.backgroundColor = .clear
        unsupportedCountryError.view.isHidden(true)
        
        var selectedAuthority: LocalAuthority?
        let localAuthorities = LocalAuthorities(localAuthorities: localAuthorityViewModel.localAuthorities) { la in
            selectedAuthority = la
        }
        let localAuthoritiesVC = UIHostingController(rootView: localAuthorities)
        localAuthoritiesVC.view.backgroundColor = .clear
        
        views = [
            UIImageView(.onboardingPostcode).styleAsDecoration(),
            BaseLabel().set(text: localize(.local_authority_information_title)).styleAsPageHeader(),
            BaseLabel()
                .set(text: localize(.local_authority_screen_description(postcode: localAuthorityViewModel.postcode)))
                .styleAsSecondaryBody(),
            LinkButton(
                title: localize(.local_authority_visit_gov_uk_link_title),
                action: interactor.didTapLink
            ),
            emptyError.view,
            unsupportedCountryError.view,
            localAuthoritiesVC.view,
        ]
        
        let contentStack = UIStackView(arrangedSubviews: views.flatMap { $0.content })
        contentStack.axis = .vertical
        contentStack.spacing = .standardSpacing
        
        let button = PrimaryButton(
            title: localize(.local_authority_confirmation_button),
            action: {
                let result = interactor.didTapSubmitButton(localAuthority: selectedAuthority)
                if case .failure(let error) = result {
                    switch error {
                    case .emptySelection:
                        emptyError.view.isHidden(false)
                        unsupportedCountryError.view.isHidden(true)
                        UIAccessibility.post(notification: .layoutChanged, argument: emptyError)
                    case .unsupportedCountry:
                        emptyError.view.isHidden(true)
                        unsupportedCountryError.view.isHidden(false)
                        UIAccessibility.post(notification: .layoutChanged, argument: unsupportedCountryError)
                    }
                } else {
                    interactor.dismiss()
                }
            }
        )
        
        let stackContent = [contentStack, button]
        let stackView = UIStackView(arrangedSubviews: stackContent)
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = .standardSpacing
        
        views = [stackView]
        
    }
}

public class SelectLocalAuthorityViewController: ScrollingContentViewController {
    
    // MARK: - Properties
    
    public typealias Interacting = SelectLocalAuthorityViewControllerInteracting
    
    // MARK: - Init
    
    public init(interactor: Interacting, localAuthorityViewModel: LocalAuthorityViewModel, hideBackButton: Bool) {
        let content = SelectLocalAuthorityContent(interactor: interactor, localAuthorityViewModel: localAuthorityViewModel)
        super.init(views: content.views)
        title = localize(.local_authority_confirmation_title)
        navigationItem.hidesBackButton = hideBackButton
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}
