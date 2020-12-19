//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

enum Asset {
    case strings(String)
    case stringsdict(String)
    case content(name: String, suffix: String)
    case bundle(String)
}
