//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation

struct Report: Codable {
    var title: String
    var sections: [Section]
    
    struct Section: Codable {
        let body: String
        let checks: [Check]
        let title: String
    }
    
    struct Check: Codable {
        let check: String
        let notes: String?
        let passed: Bool
        
        init(check: String, notes: String, passed: Bool) {
            self.check = check
            self.notes = notes.isEmpty ? nil : notes
            self.passed = passed
        }
    }
}
