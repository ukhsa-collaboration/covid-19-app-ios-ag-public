//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation

// A copy of `Common.mutating`, since we don't depend on `Common` here (it’d make our life complicated when it comes to
// linking against it in tests).
func mutating<Value>(_ value: Value, with mutate: (inout Value) throws -> Void) rethrows -> Value {
    var copy = value
    try mutate(&copy)
    return copy
}
