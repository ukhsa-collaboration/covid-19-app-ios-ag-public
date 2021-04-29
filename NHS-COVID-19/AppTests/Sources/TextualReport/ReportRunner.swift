//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation

struct ReportRunner {
    
    func run(name: String, content: () -> Report) throws {
        guard ProcessInfo().environment["test_mode"] == "textReport" else {
            return
        }
        
        let reportContent = content()
        
        let reportCollector = try ReportCollector.shared()
        try reportCollector.append(reportContent, for: name)
    }
}
