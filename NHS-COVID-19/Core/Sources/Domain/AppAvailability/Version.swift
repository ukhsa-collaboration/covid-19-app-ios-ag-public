//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

struct Version: Comparable {
    private var major: Int
    private var minor: Int
    private var patch: Int
    
    private enum Errors: Error {
        case invalidVersion(String)
    }
    
    init(major: Int, minor: Int = 0, patch: Int = 0) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }
    
    init(_ value: String) throws {
        let components = value.components(separatedBy: ".")
        let count = components.count
        
        let get = { (index: Int) -> Int? in
            if index < count {
                return Int(components[index])
            } else {
                return 0
            }
        }
        guard
            components.count <= 3,
            let major = Int(components[0]),
            let minor = get(1),
            let patch = get(2)
        else {
            throw Errors.invalidVersion(value)
        }
        self.major = major
        self.minor = minor
        self.patch = patch
    }
    
    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.canonicalRepresentation
            .compare(rhs.canonicalRepresentation, options: .numeric, range: nil, locale: nil) == .orderedAscending
    }
    
    private var canonicalRepresentation: String {
        [major, minor, patch].map(String.init).joined()
    }
}
