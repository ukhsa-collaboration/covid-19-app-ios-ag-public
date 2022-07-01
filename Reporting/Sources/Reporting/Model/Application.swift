//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

struct Application {
    var url: URL
    var appInfo: AppInfo

    var name: String {
        url.deletingPathExtension().lastPathComponent
    }

    init(url: URL) throws {
        self.url = url

        let infoURL = url.appendingPathComponent("Info.plist")
        let data = try Data(contentsOf: infoURL)
        appInfo = try PropertyListDecoder().decode(AppInfo.self, from: data)
    }
}
