//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation

struct ReportList: ReportContent {

    var items: [ReportContent]

    var markdownBody: String {
        items.lazy.map { "* \($0)" }.joined(separator: "\n")
    }

}
