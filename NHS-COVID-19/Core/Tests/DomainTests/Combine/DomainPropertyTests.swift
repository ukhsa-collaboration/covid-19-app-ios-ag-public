//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import TestSupport
import XCTest
@testable import Domain

class DomainPropertyTests: XCTestCase {
    
    func testSubscribing() {
        let initialValue = UUID()
        let newValue = UUID()
        let subject = CurrentValueSubject<UUID, Never>(initialValue)
        
        let property = subject.domainProperty()
        
        var receivedValues = [UUID]()
        
        let cancelable = property.sink {
            receivedValues.append($0)
        }
        
        subject.value = newValue
        
        cancelable.cancel()
        
        subject.value = UUID()
        
        TS.assert(receivedValues, equals: [initialValue, newValue])
    }
}
