//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Localization
import SwiftUI

public class HomeAnimationsViewModel: ObservableObject {
    @Published var isReducedMotionEnabled: Bool = false
    @Published var toggleState = false
    private var subscriptions = Set<AnyCancellable>()
    private var homeAnimationEnabled: InterfaceProperty<Bool>
    private var homeAnimationEnabledAction: (Bool) -> Void

    public init(
        homeAnimationEnabled: InterfaceProperty<Bool>,
        homeAnimationEnabledAction: @escaping (Bool) -> Void,
        reduceMotionPublisher: AnyPublisher<Bool, Never>
    ) {
        self.homeAnimationEnabled = homeAnimationEnabled
        self.homeAnimationEnabledAction = homeAnimationEnabledAction

        reduceMotionPublisher.sink(receiveValue: { [weak self] reduceMotionOn in
            guard let self = self else { return }

            if reduceMotionOn {
                self.isReducedMotionEnabled = true
                self.toggleState = false
            } else {
                self.isReducedMotionEnabled = false
                self.toggleState = self.homeAnimationEnabled.wrappedValue
            }

        }).store(in: &subscriptions)

        $toggleState
            .filter { [weak self] in self?.toggleState != $0 } // skip if the new value and the current value are the same
            .filter { [weak self] _ in self?.isReducedMotionEnabled == false } // ignore if reduce motion is enabled
            .sink { [weak self] isOn in
                self?.homeAnimationEnabledAction(isOn)
            }.store(in: &subscriptions)

    }
}

private struct HomeAnimationStateContentView: View {

    @Binding var toggleBinding: Bool
    @Binding var shouldAlertViewBePresented: Bool
    @State var shouldShowAlert: Bool = false

    private var toggleTitle: String {
        toggleBinding ?
            localize(.home_animations_toggle_description_on) :
            localize(.home_animations_toggle_description_off)
    }

    var body: some View {
        VStack(alignment: .leading) {

            if shouldAlertViewBePresented {
                Button {
                    shouldShowAlert = true
                } label: {
                    ToggleButton(
                        isToggledOn: $toggleBinding,
                        text: toggleTitle
                    ).allowsHitTesting(false)
                }.padding(.bottom)
            } else {
                ToggleButton(
                    isToggledOn: $toggleBinding,
                    text: toggleTitle
                ).padding(.bottom)
            }

            Text(localize(.home_animations_heading))
                .styleAsHeading()
                .padding()

            Text(localize(.home_animations_description))
                .styleAsBody()
                .padding()
                .layoutPriority(1)

        }
        .environment(\.locale, Locale(identifier: currentLocaleIdentifier()))
        .alert(isPresented: $shouldShowAlert, content: {
            Alert(
                title: Text(localize(.home_animations_alert_view_title)),
                message: Text(localize(.home_animations_alert_view_description)),
                dismissButton: .default(Text(.ok), action: {
                    shouldShowAlert = false
                })
            )
        })
    }
}

private struct HomeAnimationStateView: View {
    @ObservedObject private var homeAnimationState: HomeAnimationsViewModel

    init(homeAnimationState: HomeAnimationsViewModel) {
        self.homeAnimationState = homeAnimationState
    }

    var body: some View {
        ScrollView(.vertical) {
            HomeAnimationStateContentView(
                toggleBinding: $homeAnimationState.toggleState,
                shouldAlertViewBePresented: $homeAnimationState.isReducedMotionEnabled
            )
            .padding()

        }
        .background(Color(.background))
        .edgesIgnoringSafeArea(.bottom)
    }

}

public class HomeAnimationsViewController: RootViewController {
    private let viewModel: HomeAnimationsViewModel

    public init(viewModel: HomeAnimationsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

        title = localize(.home_animations_title)

        let content = UIHostingController(
            rootView: HomeAnimationStateView(homeAnimationState: viewModel)
        )
        addFilling(content)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
