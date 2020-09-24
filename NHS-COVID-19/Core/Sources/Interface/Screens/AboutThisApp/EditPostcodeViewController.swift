//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Localization
import UIKit

public protocol EditPostcodeViewControllerInteracting {
    var savePostcode: (String) -> Result<Void, DisplayableError> { get }
    var didTapCancel: () -> Void { get }
}

private class TextFieldDelegate: NSObject, UITextFieldDelegate {
    private let act: () -> Void
    
    init(act: @escaping () -> Void) {
        self.act = act
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        act()
        return false
    }
}

private class EditPostcodeContent: StickyFooterScrollingContent {
    typealias Interacting = EditPostcodeViewControllerInteracting
    private static let infoboxInset = (.stripeWidth + .stripeSpacing)
    
    private let delegate: TextFieldDelegate
    let scrollingContent: StackContent
    let footerContent: StackContent
    let spacing: CGFloat = .doubleSpacing
    
    public init(interactor: Interacting) {
        let errorTitle = UILabel()
        let errorDescription = UILabel()
        let textField = TextField(process: PostcodeProcessor.process)
        
        let informationBox = InformationBox.error(
            UILabel().set(text: localize(.postcode_entry_step_title)).styleAsPageHeader(),
            UILabel().set(text: localize(.postcode_entry_example_label)).styleAsSecondaryBody(),
            errorTitle.set(text: localize(.postcode_entry_error_title)).styleAsErrorHeading().isHidden(true),
            errorDescription.styleAsError().isHidden(true),
            textField.styleForPostcodeEntry().accessibilityLabel(localize(.postcode_entry_textfield_label))
        )
        
        let action = {
            textField.resignFirstResponder()
            guard let text = textField.text else { return }
            
            if case .failure(let error) = interactor.savePostcode(text) {
                errorTitle.isHidden = false
                errorDescription.isHidden = false
                errorDescription.text = error.localizedDescription
                informationBox.error()
                textField.layer.borderColor = UIColor(.errorRed).cgColor
                UIAccessibility.post(notification: .layoutChanged, argument: errorTitle)
            }
        }
        
        delegate = TextFieldDelegate(act: action)
        textField.delegate = delegate
        
        scrollingContent = BasicContent(
            views: [
                informationBox,
                UIStackView(content: BasicContent(
                    views: localizeAndSplit(.postcode_entry_information_description_2)
                        .map { UILabel().styleAsBody().set(text: String($0)) },
                    spacing: .standardSpacing,
                    margins: mutating(.zero) {
                        $0.left = Self.infoboxInset
                        $0.right = Self.infoboxInset
                    }
                )),
            ],
            spacing: .standardSpacing,
            margins: mutating(.largeInset) {
                $0.bottom = 0
                $0.left -= Self.infoboxInset
                $0.right -= Self.infoboxInset
            }
        )
        
        footerContent = BasicContent(
            views: [PrimaryButton(title: localize(.edit_postcode_save_button), action: action)],
            spacing: .standardSpacing,
            margins: mutating(.largeInset) { $0.top = 0 }
        )
    }
}

public class EditPostcodeViewController: StickyFooterScrollingContentViewController {
    public typealias Interacting = EditPostcodeViewControllerInteracting
    
    private let interactor: Interacting
    
    public init(interactor: Interacting) {
        self.interactor = interactor
        super.init(content: EditPostcodeContent(interactor: interactor))
        title = localize(.edit_postcode_title)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: localize(.cancel), style: .plain, target: self, action: #selector(didTapCancel))
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didTapCancel() {
        interactor.didTapCancel()
    }
}
