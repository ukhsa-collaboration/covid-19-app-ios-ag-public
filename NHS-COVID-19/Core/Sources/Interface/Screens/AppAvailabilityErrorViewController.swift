//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Localization
import UIKit

let downloadAppLink = "https://apps.apple.com/us/app/nhs-covid-19/id1520427663"

public class AppAvailabilityErrorViewController: RecoverableErrorViewController {
    public struct ViewModel {
        public enum ErrorType {
            case iOSTooOld
            case appTooOld(updateAvailable: Bool)
            case recommendingAppUpdate(title: LocaleString)
            case recommendingOSUpdate(title: LocaleString)
            
            fileprivate var title: String {
                switch self {
                case .iOSTooOld:
                    return localize(.accessability_error_os_out_of_date)
                case .appTooOld(updateAvailable: true):
                    return localize(.accessability_error_update_the_app)
                case .appTooOld(updateAvailable: false):
                    return localize(.accessability_error_cannot_run_app)
                case .recommendingAppUpdate(title: let title), .recommendingOSUpdate(title: let title):
                    return title.localizedString()
                }
            }
        }
        
        var title: String
        var descriptions: LocaleString
        var appUpdateAction: (() -> Void)?
        var appUpdateImage: UIImage?
        var secondaryBtnAction: (() -> Void)?
        
        public init(errorType: ErrorType, descriptions: LocaleString, secondaryBtnAction: (() -> Void)? = nil) {
            title = errorType.title
            self.descriptions = descriptions
            self.secondaryBtnAction = secondaryBtnAction
            switch errorType {
            case .appTooOld(updateAvailable: let updateAvailable):
                if updateAvailable {
                    appUpdateAction = updateAvailable ? downloadAppAction() : nil
                    appUpdateImage = UIImage(named: ImageName.appUpdateImage.rawValue)
                }
            case .iOSTooOld:
                appUpdateImage = UIImage(named: ImageName.appUpdateImage.rawValue)
            case .recommendingAppUpdate(title: _):
                appUpdateAction = downloadAppAction()
                appUpdateImage = UIImage(named: ImageName.appUpdateImage.rawValue)
            case .recommendingOSUpdate(title: _):
                appUpdateImage = UIImage(named: ImageName.appUpdateImage.rawValue)
            }
        }
        
        private func downloadAppAction() -> () -> Void {
            return {
                if let url = URL(string: downloadAppLink) {
                    #warning("Do not use the app singleton in the view controller")
                    UIApplication.shared.open(url)
                }
            }
        }
    }
    
    public init(viewModel: ViewModel) {
        let description = viewModel.descriptions.localizedString()
        
        var action: (title: String, act: () -> Void)?
        if let act = viewModel.appUpdateAction {
            action = (title: localize(.update_app_button_title), act: act)
        }
        
        var secondaryBtnAction: (title: String, act: () -> Void)?
        if let act = viewModel.secondaryBtnAction {
            secondaryBtnAction = (title: localize(.ask_me_later_button_title), act: act)
        }
        
        var updateImageView: UIImageView?
        if let image = viewModel.appUpdateImage {
            updateImageView = UIImageView()
            updateImageView?.contentMode = .scaleAspectFit
            updateImageView?.image = image
        }
        
        super.init(error: AppAvailabilityError(imageView: updateImageView, action: action, title: viewModel.title, description: description), isPrimaryLinkBtn: true, secondaryBtnAction: secondaryBtnAction)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private struct AppAvailabilityError: ErrorDetail {
    var imageView: UIImageView?
    var action: (title: String, act: () -> Void)?
    let title: String
    let description: String?
    var logoStrapLineStyle: LogoStrapline.Style = .onboarding
    
    var content: [UIView] {
        let label = BaseLabel()
        label.styleAsBody()
        label.text = description
        return [label]
    }
}
