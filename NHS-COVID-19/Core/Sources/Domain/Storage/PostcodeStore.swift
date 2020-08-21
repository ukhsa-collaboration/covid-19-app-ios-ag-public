//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

private struct PostcodeValidationError: Error {}

private struct PostcodeInfo: Codable, DataConvertible {
    var postcode: String
    var riskLevel: PostcodeRisk?
    
    init(_ postcode: String, riskLevel: PostcodeRisk?) {
        self.postcode = postcode
        self.riskLevel = riskLevel
    }
}

public class PostcodeStore {
    
    @Encrypted private var postcodeInfo: PostcodeInfo? {
        didSet {
            hasPostcode = $postcodeInfo.hasValue
        }
    }
    
    @Published
    public internal(set) var riskLevel: PostcodeRisk? {
        didSet {
            postcodeInfo?.riskLevel = riskLevel
        }
    }
    
    @Published
    private(set) var hasPostcode: Bool
    
    private let isValid: (_ postcode: String) -> Bool
    
    init(store: EncryptedStoring, isValid: @escaping (_ postcode: String) -> Bool) {
        _postcodeInfo = store.encrypted("postcode")
        let info = _postcodeInfo.wrappedValue
        hasPostcode = info != nil
        riskLevel = info?.riskLevel
        self.isValid = isValid
    }
    
    func save(postcode: String) throws {
        if isValid(postcode) {
            postcodeInfo = PostcodeInfo(postcode, riskLevel: riskLevel)
            Metrics.signpost(.completedOnboarding)
            return
        }
        throw PostcodeValidationError()
    }
    
    public func load() -> String? {
        postcodeInfo?.postcode
    }
    
    func delete() {
        riskLevel = nil
        postcodeInfo = nil
    }
}
