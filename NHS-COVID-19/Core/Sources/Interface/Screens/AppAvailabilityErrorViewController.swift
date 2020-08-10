//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import UIKit

public class AppAvailabilityErrorViewController: RecoverableErrorViewController {
    public struct ViewModel {
        public enum ErrorType {
            case iOSTooOld
            case appTooOld(updateAvailable: Bool)
            
            fileprivate var title: String {
                switch self {
                case .iOSTooOld:
                    return localize(.accessability_error_os_out_of_date)
                case .appTooOld(updateAvailable: true):
                    return localize(.accessability_error_update_the_app)
                case .appTooOld(updateAvailable: false):
                    return localize(.accessability_error_cannot_run_app)
                }
            }
        }
        
        var title: String
        var descriptions: [Locale: String]
        
        public init(errorType: ErrorType, descriptions: [Locale: String]) {
            title = errorType.title
            self.descriptions = descriptions
        }
    }
    
    public init(viewModel: ViewModel) {
        let description = viewModel.descriptions[Locale(identifier: "en-GB")]
        super.init(error: AppAvailabilityError(title: viewModel.title, description: description))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private struct AppAvailabilityError: ErrorDetail {
    var action: (title: String, act: () -> Void)? = nil
    let title: String
    let description: String?
    
    var content: [UIView] {
        let label = UILabel()
        label.styleAsBody()
        label.text = description
        return [label]
    }
}
