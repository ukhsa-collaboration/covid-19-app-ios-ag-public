//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

struct Git {
    
    static func fetchAndCheckoutMaster() throws {
        try fetch()
        try checkout(branch: "master")
    }
    
    // TODO: Filter after scenario, version, buildNumber.
    static func latestTag() throws -> String? {
        let tagData = try Bash.runAndCapture(
            "git describe",
            "--tags",
            "$(git rev-list --tags --max-count=1)"
        )
        
        return tagData.toString?.trimmed
    }
    
    static func tags() throws -> [String] {
        let tagData = try Bash.runAndCapture("git tag")
        
        return (tagData.toString ?? "")
            .components(separatedBy: "\n")
            .filter { !$0.isEmpty }
    }
    
    static func revision(for ref: String = "HEAD") throws -> String {
        try Bash.runAndCapture("git rev-parse \(ref)").toString ?? ""
    }
    
    static func fetch() throws {
        try Bash.run("git fetch --all --tags")
    }
    
    static func checkout(branch: String) throws {
        try Bash.run("git checkout \(branch)")
    }
    
    static func numberOfCommit(from tag: String) throws -> Int {
        let data = try Bash.runAndCapture("git rev-list \(tag)..HEAD --count")
        guard let string = data.toString?.trimmed else {
            throw CustomError("failed to count number of commits from the tag \(tag)")
        }
        
        guard let count = Int(string) else {
            throw CustomError("Not a number: \(string)")
        }
        
        return count
    }
    
    static func createTag(named: String) throws {
        try Bash.run("git tag \(named)")
    }
    
    static func add(path: String) throws {
        try Bash.run("git add \(path)")
    }
    
    static func commit(message: String) throws {
        try Bash.run("git commit -m \"\(message)\"")
    }
    
    static func push(includingTags: Bool) throws {
        var command = "git push origin"
        if includingTags {
            command = "\(command) --tags"
        }
        try Bash.run(command)
    }
    
    @discardableResult
    static func checkout(tag: String, to branch: String? = nil) throws -> String {
        let branchName = branch ?? tag
        try Bash.run("git checkout \(tag) -b \(branchName)")
        
        return branchName
    }
}
