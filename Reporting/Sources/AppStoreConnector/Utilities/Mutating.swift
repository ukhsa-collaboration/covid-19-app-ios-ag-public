//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

func mutating<T>(_ value: T, with mutate: (inout T) -> Void) -> T {
    var copy = value
    mutate(&copy)
    return copy
}

@discardableResult
func configuring<T>(_ value: T, with configure: (T) -> Void) -> T {
    configure(value)
    return value
}
