//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

struct Archive {
    private let fileManager = FileManager()
    
    var url: URL
    let application: Application
    
    init(url: URL) throws {
        self.url = url
        
        // Parse application
        let applicationsFolder = url
            .appendingPathComponent("Products")
            .appendingPathComponent("Applications")
        guard let app = try fileManager.contentsOfDirectory(atPath: applicationsFolder.path).first(where: { $0.hasSuffix(".app") }) else {
            throw CustomError("Could not find an app in archive \(url)")
        }
        application = try Application(url: applicationsFolder.appendingPathComponent(app))
    }
}
