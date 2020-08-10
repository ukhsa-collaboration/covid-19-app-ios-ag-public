//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

protocol RequestGenerator {
    func request(for path: String) -> URLRequest
}
