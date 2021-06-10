//
// Copyright © 2021 DHSC. All rights reserved.
//

import Localization
import SwiftUI
import UIKit

public enum TestingHubAccessibilityID {
    public static let bookFreeTestButton = "TestingHub.BookFreeTestButton"
    public static let findOutAboutTestingLinkButton = "TestingHub.FindOutAboutTestingLinkButton"
    public static let enterTestResultButton = "TestingHub.EnterTestResultButton"
}

private struct TestingHubView: View {
    
    private let interactor: TestingHubViewController.Interacting
    @ObservedObject private var showOrderTestButton: InterfaceProperty<Bool>
    @ObservedObject private var showFindOutAboutTestingButton: InterfaceProperty<Bool>
    
    init(
        interactor: TestingHubViewController.Interacting,
        showOrderTestButton: InterfaceProperty<Bool>,
        showFindOutAboutTestingButton: InterfaceProperty<Bool>
    ) {
        self.interactor = interactor
        self.showOrderTestButton = showOrderTestButton
        self.showFindOutAboutTestingButton = showFindOutAboutTestingButton
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 2) {
                if showOrderTestButton.wrappedValue {
                    TestingHubCell(viewModel:
                        .init(
                            title: localize(.testing_hub_row_book_free_test_title),
                            description: localize(.testing_hub_row_book_free_test_description),
                            accessibilityID: TestingHubAccessibilityID.bookFreeTestButton,
                            action: interactor.didTapBookFreeTestButton
                        )
                    )
                }
                if showFindOutAboutTestingButton.wrappedValue {
                    TestingHubCell(viewModel:
                        .init(
                            title: localize(.testing_hub_row_find_out_about_testing_title),
                            description: localize(.testing_hub_row_find_out_about_testing_description),
                            iconName: .externalLink,
                            accessibilityID: TestingHubAccessibilityID.findOutAboutTestingLinkButton,
                            action: interactor.didTapFindOutAboutTestingButton
                        )
                    )
                }
                TestingHubCell(viewModel:
                    .init(
                        title: localize(.testing_hub_row_enter_test_result_title),
                        description: localize(.testing_hub_row_enter_test_result_description),
                        accessibilityID: TestingHubAccessibilityID.enterTestResultButton,
                        action: interactor.didTapEnterTestResultButton
                    )
                )
            }
        }
        .background(Color(.background))
    }
    
}

private struct TestingHubCell: View {
    
    struct ViewModel {
        let title: String
        let description: String
        let iconName: ImageName
        let action: () -> Void
        let accessibilityID: String
        
        init(
            title: String,
            description: String,
            iconName: ImageName = .menuChevron,
            accessibilityID: String,
            action: @escaping () -> Void
        ) {
            self.title = title
            self.description = description
            self.iconName = iconName
            self.accessibilityID = accessibilityID
            self.action = action
        }
    }
    
    let viewModel: ViewModel
    
    var body: some View {
        let button = Button(action: viewModel.action) {
            HStack {
                VStack(alignment: .leading, spacing: .halfSpacing) {
                    Text(viewModel.title)
                        .styleAsHeading()
                    Text(viewModel.description)
                        .styleAsSecondaryBody()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Image(viewModel.iconName)
                    .frame(width: 24, height: 24)
                    .foregroundColor(Color(.primaryText))
            }
            .padding(24)
            .contentShape(Rectangle()) // fixes tap outside of padding
        }
        .buttonStyle(PlainButtonStyle())
        .background(Color(.surface))
        .environment(\.locale, Locale(identifier: currentLocaleIdentifier()))
        
        let resultView: AnyView
        if viewModel.iconName == .externalLink {
            let linkText = viewModel.title + ", " + viewModel.description
            resultView = AnyView(button.linkify(linkText))
        } else {
            resultView = AnyView(button)
        }
        
        return resultView.accessibility(identifier: viewModel.accessibilityID)
    }
    
}

public protocol TestingHubViewControllerInteracting {
    func didTapBookFreeTestButton()
    func didTapFindOutAboutTestingButton()
    func didTapEnterTestResultButton()
}

public class TestingHubViewController: RootViewController {
    
    public typealias Interacting = TestingHubViewControllerInteracting
    
    private let interactor: Interacting
    private let showOrderTestButton: InterfaceProperty<Bool>
    private let showFindOutAboutTestingButton: InterfaceProperty<Bool>
    
    public init(
        interactor: Interacting,
        showOrderTestButton: InterfaceProperty<Bool>,
        showFindOutAboutTestingButton: InterfaceProperty<Bool>
    ) {
        self.interactor = interactor
        self.showOrderTestButton = showOrderTestButton
        self.showFindOutAboutTestingButton = showFindOutAboutTestingButton
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        title = localize(.testing_hub_title)
        
        let testingHubView = TestingHubView(
            interactor: interactor,
            showOrderTestButton: showOrderTestButton,
            showFindOutAboutTestingButton: showFindOutAboutTestingButton
        )
        .edgesIgnoringSafeArea(.bottom)
        
        let contentViewController = UIHostingController(rootView: testingHubView)
        addFilling(contentViewController)
    }
    
}
