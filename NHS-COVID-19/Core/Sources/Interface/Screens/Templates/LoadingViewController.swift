//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import UIKit

public protocol LoadingViewControllerInteracting {
    func didTapCancel()
}

public class LoadingViewController: UIViewController {
    
    public typealias Interacting = LoadingViewControllerInteracting
    
    private let interacting: Interacting
    
    public init(interactor: Interacting, title: String) {
        interacting = interactor
        
        super.init(nibName: nil, bundle: nil)
        
        self.title = title
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func accessibilityPerformEscape() -> Bool {
        dismiss(animated: true, completion: nil)
        return true
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancel))
        
        let view = self.view!
        view.styleAsScreenBackground(with: traitCollection)
        
        let spinner = UIActivityIndicatorView()
        spinner.startAnimating()
        
        let waitingLabel = UILabel()
        waitingLabel.styleAsBody()
        waitingLabel.text = localize(.loading)
        
        view.addSubview(spinner)
        view.addAutolayoutSubview(spinner)
        
        view.addSubview(waitingLabel)
        view.addAutolayoutSubview(waitingLabel)
        
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            waitingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            waitingLabel.topAnchor.constraint(equalToSystemSpacingBelow: spinner.bottomAnchor, multiplier: 1),
        ])
    }
    
    @objc func didTapCancel() {
        interacting.didTapCancel()
    }
}
