//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

struct ReportColumnAdapter<Row> {
    var title: String
    var _makeContent: (Row) -> ReportContent
    
    init(title: String, makeContent: @escaping (Row) -> ReportContent) {
        self.title = title
        _makeContent = makeContent
    }
    
    func makeContent(for data: Row) -> ReportContent {
        _makeContent(data)
    }
}

struct ReportTable<Row>: ReportContent {
    var rows: [Row]
    var columns: [ReportColumnAdapter<Row>]
    
    var markdownBody: String {
        let titles = columns.map { $0.title }.tableRow
        let separator = Array(repeating: "-", count: columns.count).tableRow
        let dataRows = rows.map { entry -> String in
            columns.map { $0.makeContent(for: entry).markdownBody }.tableRow
        }.joined(separator: "\n")
        
        return """
        \(titles)
        \(separator)
        \(dataRows)
        """
    }
}

private extension Sequence where Element == String {
    
    var tableRow: String {
        let inner = lazy.map { $0.markdownBody }.joined(separator: "|")
        return "|\(inner)|"
    }
    
}
