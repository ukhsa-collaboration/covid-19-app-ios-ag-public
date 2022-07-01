//
// Copyright © 2021 DHSC. All rights reserved.
//

import UIKit

typealias SpacerView = UIView

extension UIView {

    var isPortrait: Bool {
        return interfaceOrientation.isPortrait
    }

    var interfaceOrientation: UIInterfaceOrientation {
        return window?.windowScene?.interfaceOrientation ?? .portrait
    }

    public func addAutolayoutSubview(_ subview: UIView) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subview)
    }

    @discardableResult
    public func resistsSizeChange(along axis: NSLayoutConstraint.Axis = .horizontal) -> UIView {
        setContentCompressionResistancePriority(.required, for: axis)
        setContentHuggingPriority(.required, for: axis)
        return self
    }

    public func addFillingSubview(_ subview: UIView, inset: CGFloat = 0) {
        addAutolayoutSubview(subview)
        NSLayoutConstraint.activate([
            subview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset),
            subview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -inset),
            subview.topAnchor.constraint(equalTo: topAnchor, constant: inset),
            subview.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -inset),
        ])
    }

    public func addReadableSubview(_ subview: UIView, inset: CGFloat = 0) {
        addAutolayoutSubview(subview)
        NSLayoutConstraint.activate([
            subview.topAnchor.constraint(equalTo: topAnchor, constant: inset),
            subview.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -inset),
            subview.leadingAnchor.constraint(equalTo: readableContentGuide.leadingAnchor, constant: inset),
            subview.trailingAnchor.constraint(equalTo: readableContentGuide.trailingAnchor, constant: -inset),
        ])
    }

    // Adds a subview with a bottom constraint that is flexible to UITableView resizing
    public func addCellContentSubview(_ subview: UIView, inset: CGFloat = 0) {
        addAutolayoutSubview(subview)
        NSLayoutConstraint.activate([
            subview.topAnchor.constraint(equalTo: topAnchor, constant: inset),
            subview.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -inset).withPriority(.almostRequest),
            subview.leadingAnchor.constraint(equalTo: readableContentGuide.leadingAnchor, constant: inset),
            subview.trailingAnchor.constraint(equalTo: readableContentGuide.trailingAnchor, constant: -inset),
        ])
    }

    @discardableResult
    func isHidden(_ hidden: Bool) -> Self {
        isHidden = hidden
        return self
    }

    func getFirstSubview<T: UIView>() -> T? {
        for subview in subviews {
            if let result = (subview as? T) ?? subview.getFirstSubview() {
                return result
            }
        }
        return nil
    }
}

// View with a keyboard

extension UIView {

    func setupKeyboardAppearance(pushedView: UIView) {

        let keyboardView = UIView()
        keyboardView.isHidden = true
        addAutolayoutSubview(keyboardView)

        NSLayoutConstraint.activate([
            pushedView.bottomAnchor.constraint(lessThanOrEqualTo: keyboardView.topAnchor, constant: -.standardSpacing),
            keyboardView.leadingAnchor.constraint(equalTo: leadingAnchor),
            keyboardView.trailingAnchor.constraint(equalTo: trailingAnchor),
            pushedView.bottomAnchor.constraint(lessThanOrEqualTo: keyboardView.topAnchor, constant: -.standardSpacing),
            keyboardView.bottomAnchor.constraint(equalTo: bottomAnchor),

        ])

        // This height will represent the portion of the view covered by a keyboard.
        // We can honour this constraint _almost_ always. However, this _could_ break temporarily before we get a chance
        // to respond, for example when device rotates. For this reason, reduce the priorty slightly.
        let keyboardHeightConstraint = keyboardView.heightAnchor.constraint(equalToConstant: 0)
            .withPriority(.almostRequest)
        keyboardHeightConstraint.isActive = true

        for name in [UIApplication.keyboardWillHideNotification, UIApplication.keyboardWillShowNotification] {
            NotificationCenter.default.addObserver(forName: name, object: nil, queue: .main) { notification in
                guard
                    let endFrame = notification.userInfo?[UIApplication.keyboardFrameEndUserInfoKey] as? CGRect
                else {
                    return
                }

                let curve = UIView.AnimationCurve(
                    rawValue: notification.userInfo?[UIApplication.keyboardAnimationCurveUserInfoKey] as? Int ?? 0
                )
                let duration = notification.userInfo?[UIApplication.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0

                UIView.animate(
                    withDuration: duration, delay: 0,
                    options: [.curve(from: curve ?? .easeInOut), .beginFromCurrentState],
                    animations: {
                        let frameInView = self.convert(endFrame, from: UIScreen.main.coordinateSpace)
                        keyboardHeightConstraint.constant = max(0, self.bounds.maxY - frameInView.minY)
                        self.layoutIfNeeded()
                    }, completion: nil
                )
            }
        }
    }
}
