//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Foundation
import UserNotifications

struct LocalInformationChangeNotifier {
    
    var notificationManager: UserNotificationManaging
    
    private static let postcodePlaceholder = "[postcode]"
    private static let localAuthorityPlaceholder = "[local authority]"
    
    func alertUserToChanges<P: Publisher>(
        in localInfo: P,
        localAuthority: AnyPublisher<LocalAuthority?, Never>,
        languageCode: AnyPublisher<String?, Never>,
        postcode: AnyPublisher<Postcode?, Never>,
        localAuthorityValidator: LocalAuthoritiesValidator
    ) -> AnyCancellable where P.Output == LocalInformationEndpointManager.LocalInfo?, P.Failure == Never {
        localInfo
            .combineLatest(localAuthority, languageCode, postcode)
            .sink { localInfoWrapper, localAuthority, languageCode, postcode in
                
                // check that the local authorities match
                guard let localAuthorityId = localAuthority?.id,
                    localAuthorityId == localInfoWrapper?.localAuthority?.id,
                    let localAuthorityName = localAuthority?.name,
                    let postcode = postcode else {
                    return
                }
                
                guard let localAuthority = localAuthority else {
                    return
                }
                let result = localAuthorityValidator.localAuthorities(for: postcode)
                if case .success(let localAuthorities) = result {
                    if !localAuthorities.contains(localAuthority) {
                        // got an update where the postcode and LA don't match
                        return
                    }
                } else {
                    // something else wrong with the postcode
                    return
                }
                
                // get the current language code
                let languageCode = languageCode ?? Locale.current.languageCode
                
                // check we've translations for this
                guard let message = localInfoWrapper?.info?.translations(for: languageCode) else {
                    return
                }
                
                if localInfoWrapper?.notify ?? false, let head = message.head {
                    Metrics.signpost(.didSendLocalInfoNotification)
                    
                    #warning("put in an integration adaptor")
                    let notificationTitle: String = {
                        head
                            .replacingOccurrences(of: Self.postcodePlaceholder, with: postcode.value)
                            .replacingOccurrences(of: Self.localAuthorityPlaceholder, with: localAuthorityName)
                    }()
                    
                    let notificationBody: String = {
                        guard let message = message.body else {
                            return ""
                        }
                        return message
                            .replacingOccurrences(of: Self.postcodePlaceholder, with: postcode.value)
                            .replacingOccurrences(of: Self.localAuthorityPlaceholder, with: localAuthorityName)
                    }()
                    
                    self.notificationManager.add(
                        type: .localMessage(title: notificationTitle, body: notificationBody),
                        at: nil,
                        withCompletionHandler: nil
                    )
                }
            }
    }
}
