//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

struct ReportSection {
    var title: String
    var content: ReportContent

    var body: String
    var checks: [IntegrityCheck]?
    var attributes: [AppAttribute]?

    var markdownBody: String {
        """
        ### \(title)

        \(content.markdownBody)
        """
    }

}

extension ReportSection {
    init(title: String, content: ReportContent) {
        self.init(
            title: title,
            content: content,
            body: content.markdownBody
        )
    }

    init(title: String, checks: [IntegrityCheck]) {
        self.init(
            title: title,
            content: ReportTable(checks: checks),
            body: "",
            checks: checks
        )
    }

    init(title: String, attributes: [AppAttribute]) {
        let table = ReportTable(
            rows: attributes,
            columns: [
                ReportColumnAdapter(title: "Attribute", makeContent: { $0.name }),
                ReportColumnAdapter(title: "Value", makeContent: { $0.value ?? "❌ missing" }),
            ]
        )
        self.init(
            title: title,
            content: table,
            body: "",
            attributes: attributes
        )
    }
}
