//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Foundation

@available(*, deprecated, message: "Use PublishedEncrypted instead.")
@propertyWrapper
struct Encrypted<Wrapped: DataConvertible> {

    private let dataEncryptor: DataEncrypting

    init(_ dataEncryptor: DataEncrypting) {
        self.dataEncryptor = dataEncryptor
    }

    var projectedValue: Self {
        self
    }

    var wrappedValue: Wrapped? {
        get {
            dataEncryptor.wrappedValue.flatMap { try? Wrapped(data: $0) }
        }

        nonmutating set {
            dataEncryptor.wrappedValue = newValue?.data
        }

    }

    var hasValue: Bool {
        dataEncryptor.hasValue
    }

}

@propertyWrapper
struct PublishedEncrypted<Wrapped: DataConvertible> {
    private let subject = CurrentValueSubject<Wrapped?, Never>(nil)
    private let dataEncryptor: DataEncrypting

    init(_ dataEncryptor: DataEncrypting) {
        self.dataEncryptor = dataEncryptor
        subject.value = dataEncryptor.wrappedValue.flatMap { try? Wrapped(data: $0) }
    }

    var projectedValue: DomainProperty<Wrapped?> {
        return subject.domainProperty()
    }

    var wrappedValue: Wrapped? {
        get {
            subject.value
        }
        set {
            dataEncryptor.wrappedValue = newValue?.data
            subject.value = newValue
        }
    }

    var hasValue: Bool {
        subject.value != nil
    }
}
