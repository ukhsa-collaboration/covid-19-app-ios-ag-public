//
// Copyright © 2020 NHSX. All rights reserved.
//

import Domain
import Interface

extension DomainProperty {
    var interfaceProperty: InterfaceProperty<Value> {
        property(initialValue: currentValue)
    }
}
