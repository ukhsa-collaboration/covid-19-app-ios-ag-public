//
// Copyright © 2020 NHSX. All rights reserved.
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
        
        let title = UILabel()
        title.styleAsPageHeader()
        title.text = "Feature-Toggle"
        
        let riskyPostcode = createToggle(
            feature: .riskyPostcode,
            isOn: featureToggleStorage.riskyPostcodeToggle,
            action: #selector(toggleRiskyPostcode)
        )
        let venueCheckIn = createToggle(
            feature: .venueCheckIn,
            isOn: featureToggleStorage.venueCheckInToggle,
            action: #selector(toggleVenueCheckIn)
        )
        let selfDiagnosis = createToggle(
            feature: .selfDiagnosis,
            isOn: featureToggleStorage.selfDiagnosisToggle,
            action: #selector(toggleSelfDiagnosis)
        )
        let selfDiagnosisUpload = createToggle(
            feature: .selfDiagnosisUpload,
            isOn: featureToggleStorage.selfDiagnosisUploadToggle,
            action: #selector(toggleSelfDiagnosisUpload)
        )
        let selfIsolating = createToggle(
            feature: .selfIsolation,
            isOn: featureToggleStorage.selfIsolationToggle,
            action: #selector(toggleSelfIsolation)
        )
        let testKitOrder = createToggle(
            feature: .testKitOrder,
            isOn: featureToggleStorage.testKitOrderToggle,
            action: #selector(toggleTestKitOrder)
        )
        
        let stackView = UIStackView(arrangedSubviews: [
            title,
            riskyPostcode,
            venueCheckIn,
            selfDiagnosis,
            selfDiagnosisUpload,
            selfIsolating,
            testKitOrder,
        ]
        )
        
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
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
        case .riskyPostcode:
            return "Risky Postcodes"
        case .venueCheckIn:
            return "Venue Check-In"
        case .selfDiagnosis:
            return "Self Diagnosis"
        case .selfDiagnosisUpload:
            return "Self Diagnosis Upload"
        case .selfIsolation:
            return "Self Isolation"
        case .testKitOrder:
            return "Test Kit Order"
        case .pilotActivation:
            return "Pilot activation"
        }
    }
    
    @objc private func toggleRiskyPostcode() {
        featureToggleStorage.riskyPostcodeToggle.toggle()
    }
    
    @objc private func toggleVenueCheckIn() {
        featureToggleStorage.venueCheckInToggle.toggle()
    }
    
    @objc private func toggleSelfDiagnosis() {
        featureToggleStorage.selfDiagnosisToggle.toggle()
    }
    
    @objc private func toggleSelfDiagnosisUpload() {
        featureToggleStorage.selfDiagnosisUploadToggle.toggle()
    }
    
    @objc private func toggleSelfIsolation() {
        featureToggleStorage.selfIsolationToggle.toggle()
    }
    
    @objc private func toggleTestKitOrder() {
        featureToggleStorage.testKitOrderToggle.toggle()
    }
}

extension CaseIterable where Self: Equatable {
    var index: Self.AllCases.Index? {
        Self.allCases.firstIndex { self == $0 }
    }
}
