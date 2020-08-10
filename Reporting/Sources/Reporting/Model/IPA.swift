//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

struct IPA {
    
    var url: URL
    
    func withApplication(perform work: (Application) throws -> Void) throws {
        let fileManager = FileManager()
        let tempURL = try fileManager.url(for: .itemReplacementDirectory, in: .userDomainMask, appropriateFor: url, create: true)
        try Bash.run("unzip", "\(url.path)", "-d", "'\(tempURL.path)'")
        let applicationsFolder = tempURL.appendingPathComponent("Payload")
        guard let app = try fileManager.contentsOfDirectory(atPath: applicationsFolder.path).first(where: { $0.hasSuffix(".app") }) else {
            throw CustomError("Could not extract an app from \(url)")
        }
        defer { try? fileManager.removeItem(at: tempURL) }
        
        let application = try Application(url: applicationsFolder.appendingPathComponent(app))
        try work(application)
    }
    
}
