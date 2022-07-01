//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

struct UseCase: Codable {

    struct Screenshot: Codable {
        var fileName: String
        var tags: [String]
    }

    struct Step: Codable {
        var name: String
        var description: String
        var screenshots: [Screenshot] = []
    }

    var kind: String
    var scenario: String
    var name: String
    var description: String
    var steps: [Step] = []
}

extension UseCase {

    var manifestFileName: String {
        "\(baseFileName).json"
    }

    var screenshotsFolderName: String {
        baseFileName
    }

    private var baseFileName: String {
        [kind, scenario, name].joined(separator: " - ")
    }

}
