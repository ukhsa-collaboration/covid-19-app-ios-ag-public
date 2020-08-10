//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
import MetricKit

public protocol MetricPayload {
    var timeStampBegin: Date { get }
    var timeStampEnd: Date { get }
    var networkTransferMetrics: MXNetworkTransferMetric? { get }
    var latestApplicationVersion: String { get }
    var includesMultipleApplicationVersions: Bool { get }
    var metaData: MXMetaData? { get }
    var signpostMetrics: [MXSignpostMetric]? { get }
}

extension MXMetricPayload: MetricPayload {}
