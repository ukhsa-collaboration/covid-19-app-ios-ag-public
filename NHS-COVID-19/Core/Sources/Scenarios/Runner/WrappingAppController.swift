//
// Copyright © 2021 DHSC. All rights reserved.
//

import Domain
import Integration
import Interface
import SwiftUI
import UIKit

class WrappingViewController: UIViewController {
    var developerOptionsView: UIView!
    var developerOptionsViewWidth = CGFloat(50)
    var developerOptionsViewOriginalOffset = CGSize.zero
    lazy var developerOptionsViewDragOffset = CGSize(
        width: view.frame.size.width - (developerOptionsViewWidth / 2),
        height: view.frame.size.height / 3
    ) {
        didSet { relayout() }
    }

    func addDeveloperOptions(
        onTap: @escaping () -> Void,
        onLongPress: @escaping () -> Void
    ) {
        let childViewController = UIHostingController(
            rootView: DeveloperOptionsView(
                viewEvents: DeveloperOptionsViewEvents(
                    onTap: onTap,
                    onLongPress: onLongPress
                )
            )
        )
        addChild(childViewController)
        view.addSubview(childViewController.view)
        childViewController.didMove(toParent: self)
        developerOptionsView = childViewController.view
        developerOptionsView.backgroundColor = .clear
        addPanGestureRecognizer(roundView: childViewController.view)
        relayout()
    }

    func addPanGestureRecognizer(roundView: UIView) {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(developerOptionsViewPanned))
        developerOptionsView.addGestureRecognizer(panGestureRecognizer)
    }

    private func relayout() {
        developerOptionsView.frame = CGRect(
            x: developerOptionsViewDragOffset.width,
            y: developerOptionsViewDragOffset.height,
            width: developerOptionsViewWidth,
            height: developerOptionsViewWidth
        )
        developerOptionsView.layoutIfNeeded()
    }

    @objc func developerOptionsViewPanned(_ gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            developerOptionsViewOriginalOffset = developerOptionsViewDragOffset
        case .changed:
            let translation = gestureRecognizer.translation(in: view)
            developerOptionsViewDragOffset.height = developerOptionsViewOriginalOffset.height + translation.y
            developerOptionsViewDragOffset.width = developerOptionsViewOriginalOffset.width + translation.x
        default: break
        }
    }
}

class WrappingAppController: AppController {
    let rootViewController: UIViewController = WrappingViewController()

    var content: AppController? {
        didSet {
            oldValue?.rootViewController.dismiss(animated: false, completion: nil)
            oldValue?.rootViewController.remove()
            if let content = content {
                rootViewController.addFilling(content.rootViewController)
            }
        }
    }

    func performBackgroundTask(task: BackgroundTask) {
        content?.performBackgroundTask(task: task)
    }

    func handleUserNotificationResponse(_ response: UNNotificationResponse, completionHandler: @escaping () -> Void) {
        content?.handleUserNotificationResponse(response, completionHandler: completionHandler)
    }
}
