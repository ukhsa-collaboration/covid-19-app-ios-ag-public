//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Interface

struct LinkTestResultInteractor: LinkTestResultViewController.Interacting {
    var _submit: (String) -> AnyPublisher<Void, DisplayableError>
    
    func submit(testCode: String) -> AnyPublisher<Void, DisplayableError> {
        _submit(testCode)
    }
}
