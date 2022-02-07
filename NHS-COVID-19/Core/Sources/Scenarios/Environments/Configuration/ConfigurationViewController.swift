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
        
        let newNoSymptomsScreenToggle = createToggle(feature: .newNoSymptomsScreen, isOn: featureToggleStorage.newNoSymptomsScreenToggle, action: #selector(toggleNewNoSymptomsScreen))
        let localStatsButtonToggle = createToggle(feature: .localStatistics, isOn: featureToggleStorage.localStatisticsToggle, action: #selector(toggleLocalStatistics))
        
        let stackView = UIStackView(arrangedSubviews: [
            newNoSymptomsScreenToggle,
            localStatsButtonToggle,
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
        case .newNoSymptomsScreen:
            return "New \"No Symptoms\" Screen"
        case .localStatistics:
            return "Local statistics home screen button"
        }
    }
    
    @objc private func toggleNewNoSymptomsScreen() {
        featureToggleStorage.newNoSymptomsScreenToggle.toggle()
    }
    
    @objc private func toggleLocalStatistics() {
        featureToggleStorage.localStatisticsToggle.toggle()
    }
}

extension CaseIterable where Self: Equatable {
    var index: Self.AllCases.Index? {
        Self.allCases.firstIndex { self == $0 }
    }
}
