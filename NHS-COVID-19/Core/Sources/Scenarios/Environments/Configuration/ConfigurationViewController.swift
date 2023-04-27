//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Domain
import UIKit

class ConfigurationViewController: UIViewController {
    var featureToggleStorage = FeatureToggleStorage()

    init() {
        super.init(nibName: nil, bundle: nil)
        title = "Features"
        tabBarItem.image = UIImage(systemName: "smallcircle.circle")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let view = self.view!
        view.styleAsScreenBackground(with: traitCollection)
        view.insetsLayoutMarginsFromSafeArea = true

        let disclaimer = UILabel()
        disclaimer.styleAsBody()
        disclaimer.text = """
        Use these toggles to turn on and off experimental features.

        Although that should normally not be the case, note that in rare situations the app may behave incorrectly if \
        the feature toggle is changed after onboarding.
        """

        let localStatsButtonToggle = createToggle(feature: .localStatistics, isOn: featureToggleStorage.localStatisticsToggle, action: #selector(toggleLocalStatistics))
        let venueCheckInToggle = createToggle(feature: .venueCheckIn, isOn: featureToggleStorage.venueCheckInToggle, action: #selector(toggleVenueCheckIn))
        let contactOptOutFlowEnglandToggle = createToggle(feature: .contactOptOutFlowEngland, isOn: featureToggleStorage.englandOptOutFlowToggle, action: #selector(toggleContactOptOutFlowEngland))
        let contactOptOutFlowWalesToggle = createToggle(feature: .contactOptOutFlowWales, isOn: featureToggleStorage.walesOptOutFlowToggle, action: #selector(toggleContactOptOutFlowWales))
        let testingForCOVID19Toggle = createToggle(feature: .testingForCOVID19, isOn: featureToggleStorage.testingForCOVID19Toggle, action: #selector(toggleTestingForCOVID19))
        let selfIsolationHubToggleEngland = createToggle(feature: .selfIsolationHubEngland, isOn: featureToggleStorage.selfIsolationHubToggleEngland, action: #selector(toggleSelfIsolationHubEngland))
        let selfIsolationHubToggleWales = createToggle(feature: .selfIsolationHubWales, isOn: featureToggleStorage.selfIsolationHubToggleWales, action: #selector(toggleSelfIsolationHubWales))
        let guidanceHubEnglandToggle = createToggle(feature: .guidanceHubEngland, isOn: featureToggleStorage.guidanceHubEnglandToggle, action: #selector(toggleGuidanceHubEngland))
        let guidanceHubWalesToggle = createToggle(feature: .guidanceHubWales, isOn: featureToggleStorage.guidanceHubWalesToggle, action: #selector(toggleGuidanceHubWales))
        let selfReportingToggle = createToggle(feature: .selfReporting, isOn: featureToggleStorage.selfReportingToggle, action: #selector(toggleSelfReporting))
        let decommissioningClosureSceenToggle = createToggle(feature: .decommissioningClosureSceen, isOn: featureToggleStorage.decommissioningClosureSceenToggle, action: #selector(toggleDecommissioningClosureSceen))

        let stackView = UIStackView(arrangedSubviews: [
            localStatsButtonToggle,
            venueCheckInToggle,
            testingForCOVID19Toggle,
            selfIsolationHubToggleEngland,
            selfIsolationHubToggleWales,
            contactOptOutFlowEnglandToggle,
            contactOptOutFlowWalesToggle,
            guidanceHubEnglandToggle,
            guidanceHubWalesToggle,
            selfReportingToggle,
            decommissioningClosureSceenToggle,
            disclaimer,
        ])

        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = .standardSpacing
        view.addAutolayoutSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            stackView.topAnchor.constraint(greaterThanOrEqualTo: view.layoutMarginsGuide.topAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.layoutMarginsGuide.centerYAnchor),
        ])
    }

    func createToggle(feature: Feature, isOn: Bool, action: Selector) -> UIView {
        let toggle = UISwitch()
        toggle.isOn = isOn
        toggle.tag = feature.index!
        toggle.addTarget(self, action: action, for: .valueChanged)

        let label = UILabel()
        label.text = getFeatureString(feature: feature)
        let stackView = UIStackView(arrangedSubviews: [label, toggle])
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        return stackView
    }

    func getFeatureString(feature: Feature) -> String {
        switch feature {
        case .decommissioningClosureSceen:
            return "Decommissioning Closure Sceen"
        case .localStatistics:
            return "Local statistics home screen button"
        case .venueCheckIn:
            return "Venue check-in home screen button"
        case .contactOptOutFlowEngland:
            return "England opt out flow"
        case .contactOptOutFlowWales:
            return "Wales opt out flow"
        case .testingForCOVID19:
            return "Testing for COVID-19 Home Screen button"
        case .selfIsolationHubEngland:
            return "Self Isolation Home Screen button England"
        case .selfIsolationHubWales:
            return "Self Isolation Home Screen button Wales"
        case .guidanceHubEngland:
            return "COVID-19 Guidance Home Screen button England"
        case .guidanceHubWales:
            return "COVID-19 Guidance Home Screen button Wales"
        case .selfReporting:
            return "Self Reporting"
        }
    }

    @objc private func toggleLocalStatistics() {
        featureToggleStorage.localStatisticsToggle.toggle()
    }

    @objc private func toggleVenueCheckIn() {
        featureToggleStorage.venueCheckInToggle.toggle()
    }

    @objc private func toggleContactOptOutFlowEngland() {
        featureToggleStorage.englandOptOutFlowToggle.toggle()
    }

    @objc private func toggleContactOptOutFlowWales() {
        featureToggleStorage.walesOptOutFlowToggle.toggle()
    }

    @objc private func toggleTestingForCOVID19() {
        featureToggleStorage.testingForCOVID19Toggle.toggle()
    }

    @objc private func toggleSelfIsolationHubEngland() {
        featureToggleStorage.selfIsolationHubToggleEngland.toggle()
    }

    @objc private func toggleSelfIsolationHubWales() {
        featureToggleStorage.selfIsolationHubToggleWales.toggle()
    }

    @objc private func toggleGuidanceHubEngland() {
        featureToggleStorage.guidanceHubEnglandToggle.toggle()
    }

    @objc private func toggleGuidanceHubWales() {
        featureToggleStorage.guidanceHubWalesToggle.toggle()
    }

    @objc private func toggleSelfReporting() {
        featureToggleStorage.selfReportingToggle.toggle()
    }

    @objc private func toggleDecommissioningClosureSceen() {
        featureToggleStorage.decommissioningClosureSceenToggle.toggle()
    }
}

extension CaseIterable where Self: Equatable {
    var index: Self.AllCases.Index? {
        Self.allCases.firstIndex { self == $0 }
    }
}
