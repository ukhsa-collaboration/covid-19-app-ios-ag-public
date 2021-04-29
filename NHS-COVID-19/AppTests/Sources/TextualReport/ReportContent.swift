//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation

protocol ReportContent {
    var markdownBody: String { get }
}

extension String: ReportContent {
    
    var markdownBody: String {
        self
    }
    
}
