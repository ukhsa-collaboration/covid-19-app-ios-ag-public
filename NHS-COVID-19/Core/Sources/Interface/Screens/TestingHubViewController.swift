//
// Copyright © 2021 DHSC. All rights reserved.
//

import Localization
import SwiftUI
import UIKit

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
            VStack(spacing: .halfHairSpacing) {
                if showOrderTestButton.wrappedValue {
                    HubButtonCell(viewModel:
                        .init(
                            title: localize(.testing_hub_row_book_lab_test_title),
                            description: localize(.testing_hub_row_book_lab_test_description),
                            action: interactor.didTapBookFreeTestButton
                        )
                    )
                }
                if showFindOutAboutTestingButton.wrappedValue {
                    HubButtonCell(viewModel:
                        .init(
                            title: localize(.testing_hub_row_order_free_test_title),
                            description: localize(.testing_hub_row_order_free_test_description),
                            iconName: .externalLink,
                            action: interactor.didTapOrderAFreeTestingKit
                        )
                    )
                }
                HubButtonCell(viewModel:
                    .init(
                        title: localize(.testing_hub_row_enter_test_result_title),
                        description: localize(.testing_hub_row_enter_test_result_description),
                        action: interactor.didTapEnterTestResultButton
                    )
                )
            }
        }
        .padding(.bottom, .bigSpacing)
        .background(Color(.background))
    }

}

public protocol TestingHubViewControllerInteracting {
    func didTapBookFreeTestButton()
    func didTapOrderAFreeTestingKit()
    func didTapEnterTestResultButton()
    func didTapFindOutAboutTestingLink()
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

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}
