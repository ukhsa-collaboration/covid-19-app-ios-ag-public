//
// Copyright © 2020 NHSX. All rights reserved.
//

import ArgumentParser
import Foundation

struct ConfigureCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "configure",
        abstract: "Produces report from an Xcode project."
    )
    
    @Option(help: "Base64 encoded provisioning profile.")
    var base64EncodedProfile: String
    
    @Option(help: "Base64 encoded p12 file containing the signing key and certificate.")
    var base64EncodedIdentity: String
    
    @Option(help: "Password for the identity file.")
    var identityPassword: String
    
    func run() throws {
        try install(base64EncodedProfile)
        try install(base64EncodedIdentity, with: identityPassword)
    }
    
    private func install(_ base64EncodedProfile: String) throws {
        guard let profile = Data(base64Encoded: base64EncodedProfile) else {
            throw CustomError("Profile data is not base64 encoded.")
        }
        
        let fileManager = FileManager()
        let profilesFolder = fileManager
            .homeDirectoryForCurrentUser
            .appendingPathComponent("Library")
            .appendingPathComponent("MobileDevice")
            .appendingPathComponent("Provisioning Profiles")
        
        try? fileManager.createDirectory(
            at: profilesFolder,
            withIntermediateDirectories: true,
            attributes: nil
        )
        
        let profileFile = profilesFolder
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("mobileprovision")
        
        try profile.write(to: profileFile)
    }
    
    private func install(_ base64EncodedIdentity: String, with password: String) throws {
        guard let identity = Data(base64Encoded: base64EncodedIdentity) else {
            throw CustomError("Identity data is not base64 encoded.")
        }
        
        let fileManager = FileManager()
        let currentDirectory = URL(fileURLWithPath: fileManager.currentDirectoryPath)
        
        let identityFile = currentDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("p12")
        
        try identity.write(to: identityFile)
        
        let keychainPassword = UUID().uuidString
        let keychainName = UUID().uuidString
        
        try Bash.run("security", "create-keychain", "-p", keychainPassword, keychainName)
        try Bash.run("security", "list-keychains", "-d", "user", "-s", "login.keychain", keychainName)
        try Bash.run(
            "security",
            "import",
            identityFile.path,
            "-k",
            keychainName,
            "-P",
            password,
            "-T",
            "/usr/bin/codesign",
            "-T",
            "/usr/bin/security"
        )
        try Bash.run("security", "set-keychain-settings", "-lut", "6000", keychainName)
        try Bash.run("security", "unlock-keychain", "-p", keychainPassword, keychainName)
        try Bash.run("security", "set-key-partition-list", "-S", "apple-tool:,apple:", "-s", "-k", keychainPassword, keychainName)
        
        try fileManager.removeItem(at: identityFile)
    }
    
}
