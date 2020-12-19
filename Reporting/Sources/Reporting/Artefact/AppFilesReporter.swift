//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

struct AppFilesReporter {
    
    func reportSections(forAppAt appURL: URL, info: AppInfo) -> [ReportSection] {
        guard var context = FileReporterContext(appInfo: info, appURL: appURL) else {
            return [ReportSection(title: "Bundle Files", content: "❌ Could not process bundle")]
        }
        
        return [
            contentIntegrityChecks(with: &context),
            executableSecurityChecks(with: &context),
            linkedLibraries(with: &context),
            embeddedFrameworks(with: &context),
        ]
    }
    
    private func linkedLibraries(with context: inout FileReporterContext) -> ReportSection {
        
        let linkedLibraries = context.findLinkedLibraries()
        guard !linkedLibraries.isEmpty else {
            return ReportSection(title: "Linked Libraries", content: "No linked libraries detected.")
        }
        
        let list = ReportList(items: linkedLibraries)
        
        return ReportSection(title: "Linked Libraries", content: list)
    }
    
    private func embeddedFrameworks(with context: inout FileReporterContext) -> ReportSection {
        
        let embeddedFrameworks = context.findEmbeddedFrameworks()
        guard !embeddedFrameworks.isEmpty else {
            return ReportSection(title: "Embedded Frameworks", content: "No (non-Apple) frameworks detected.")
        }
        
        let list = ReportList(items: embeddedFrameworks)
        
        return ReportSection(title: "Embedded Frameworks", content: list)
    }
    
    private func contentIntegrityChecks(with context: inout FileReporterContext) -> ReportSection {
        
        ReportSection(title: "Contents", checks: [
            IntegrityCheck(name: "Has icons", result: context.checkHasIconFiles()),
            IntegrityCheck(name: "Has launch storyboard", result: context.checkHasLaunchStoryboard()),
            IntegrityCheck(name: "Has the required common files", result: context.checkHasRequiredFiles()),
            IntegrityCheck(name: "Has bundle executable", result: context.checkHasBundleExecutable()),
            IntegrityCheck(name: "All files are known", result: context.checkHasNoUnexptectedFilesLeft()),
        ])
    }
    
    private func executableSecurityChecks(with context: inout FileReporterContext) -> ReportSection {
        guard let checker = ExecutableChecker(appURL: context.appURL, appInfo: context.appInfo) else {
            return ReportSection(title: "Executable", content: "Could not find the executable")
        }
        
        return ReportSection(title: "Executable", checks: [
            IntegrityCheck(name: "Does not include paths on the build machine", result: checker.checkHasNoAbsolutePaths()),
        ])
    }
    
    func attachments(forAppAt appURL: URL, info: AppInfo) -> [ReportAttachment] {
        guard let context = FileReporterContext(appInfo: info, appURL: appURL) else {
            return []
        }
        
        return [
            context.icon,
        ]
        .compactMap { $0 }
    }
    
}

private struct AppResource {
    var url: URL
    var pathInBundle: String
    
    init(url: URL, appURL: URL) {
        precondition(url.path.hasPrefix(appURL.path))
        self.url = url
        pathInBundle = String(url.path.dropFirst(appURL.path.count).trimmingCharacters(in: .pathSeparator))
    }
}

private extension CharacterSet {
    
    static let pathSeparator = CharacterSet(charactersIn: "/")
    
}

private struct FileReporterContext {
    var appInfo: AppInfo
    var appURL: URL
    var filesByPathInBundle: [String: URL]
    
    var unaccountedFilePaths: Set<String>
    
    init?(appInfo: AppInfo, appURL: URL) {
        let fileManager = FileManager()
        guard let enumerator = fileManager.enumerator(at: appURL, includingPropertiesForKeys: nil, options: [], errorHandler: nil) else {
            return nil
        }
        
        self.appInfo = appInfo
        self.appURL = appURL
        filesByPathInBundle = Dictionary(uniqueKeysWithValues: enumerator
            .lazy
            .map { ($0 as! URL).resolvingSymlinksInPath() }
            .map { url in
                precondition(url.path.hasPrefix(appURL.path))
                let pathInBundle = String(url
                    .path
                    .dropFirst(appURL.path.count)
                    .trimmingCharacters(in: .pathSeparator)
                )
                return (pathInBundle, url)
            }
        )
        
        unaccountedFilePaths = Set(filesByPathInBundle.keys)
        
        // These are always allowed:
        unaccountedFilePaths.remove("Frameworks") // Folder
        unaccountedFilePaths.remove("_CodeSignature") // Folder
        unaccountedFilePaths.remove("PlugIns") // Folder
        unaccountedFilePaths.remove("embedded.mobileprovision")
        unaccountedFilePaths.remove("libswiftRemoteMirror.dylib")
        unaccountedFilePaths.remove("Assets.car")
        
        unaccountedFilePaths = unaccountedFilePaths.filter {
            let isTest = $0.hasPrefix("PlugIns/") && $0.contains(".xctest")
            return !isTest
        }
        
        unaccountedFilePaths = unaccountedFilePaths.filter {
            let isLocalizationFolder = $0.matches("\\w+.lproj")
            return !isLocalizationFolder
        }
    }
    
}

extension FileReporterContext {
    
    mutating func checkHasRequiredFiles() -> IntegrityCheck.Result {
        
        for fileName in ["Info.plist", "_CodeSignature/CodeResources", "PkgInfo"] {
            guard filesByPathInBundle[fileName] != nil else {
                return .failed(message: "Expected file \(fileName).")
            }
            
            unaccountedFilePaths.remove(fileName)
        }
        
        return .passed
    }
    
    mutating func checkHasBundleExecutable() -> IntegrityCheck.Result {
        guard let binaryName = appInfo.value(for: \.bundleExecutable) else {
            return .failed(message: "No binary executable name specified.")
        }
        
        guard filesByPathInBundle[binaryName] != nil else {
            return .failed(message: "Expected app to have binary executable at `\(binaryName)`.")
        }
        
        unaccountedFilePaths.remove(binaryName)
        
        return .passed
    }
    
    mutating func checkHasIconFiles() -> IntegrityCheck.Result {
        let appInfo = self.appInfo
        let iconFiles = Set([\AppInfo.bundleIcons, \AppInfo.bundleIconsForIpad]
            .lazy
            .compactMap {
                appInfo.value(for: $0)
            }
            .flatMap {
                $0.primary.files
            }
        )
        guard !iconFiles.isEmpty else {
            return .failed(message: "No icon files specified.")
        }
        
        for file in iconFiles {
            let result = checkHasFiles(for: "Expected icon files for `\(file)`") {
                $0.hasPrefix(file) && $0.hasSuffix(".png")
            }
            switch result {
            case .passed:
                break
            default:
                return result
            }
        }
        
        return .passed
    }
    
    mutating func checkHasLaunchStoryboard() -> IntegrityCheck.Result {
        guard let launchStoryboardName = appInfo.value(for: \.launchStoryboardName) else {
            return .failed(message: "No launch storyboard name specified.")
        }
        
        guard checkForStoryboard(named: launchStoryboardName) else {
            return .failed(message: "Expected app to have launch storyboard named `\(launchStoryboardName)`.")
        }
        
        return .passed
    }
    
    mutating func findEmbeddedFrameworks() -> [String] {
        let frameworkNames = unaccountedFilePaths
            .filter {
                $0.hasPrefix("Frameworks/") && $0.hasSuffix(".framework")
            }
            .map { path in
                String(
                    path.dropFirst("Frameworks/".count)
                        .dropLast(".framework".count)
                )
            }
        
        for name in frameworkNames {
            let prefix = "Frameworks/\(name).framework"
            unaccountedFilePaths = unaccountedFilePaths.filter {
                !$0.hasPrefix(prefix)
            }
        }
        
        return frameworkNames.sorted()
    }
    
    mutating func findLinkedLibraries() -> [String] {
        guard let executableChecker = ExecutableChecker(appURL: appURL, appInfo: appInfo) else {
            return []
        }
        
        return executableChecker.linkedLibraries
    }
    
    mutating func checkHasNoUnexptectedFilesLeft() -> IntegrityCheck.Result {
        for asset in App.knownAssets {
            _ = check(for: asset)
        }
        
        if unaccountedFilePaths.isEmpty {
            return .passed
        } else {
            let list = ReportList(
                items: unaccountedFilePaths.sorted().map { "`\($0)`" }
            )
            return .failed(message: "Found unexpected files:\n\n\(list.markdownBody)")
        }
    }
    
    private mutating func check(for asset: Asset) -> Bool {
        switch asset {
        case .bundle(let name):
            return checkForLocalizableFile(named: name, suffix: "bundle", isFolder: true)
        case .strings(let name):
            return checkForLocalizableFile(named: name, suffix: "strings")
        case .stringsdict(let name):
            return checkForLocalizableFile(named: name, suffix: "stringsdict")
        case .content(let name, let suffix):
            return checkForFile(named: name, suffix: suffix)
        }
    }
    
    private mutating func checkForStoryboard(named name: String) -> Bool {
        checkForLocalizableFile(named: name, suffix: "storyboardc", isFolder: true)
    }
    
    private mutating func checkForFile(named name: String, suffix: String) -> Bool {
        let fileName = "\(name).\(suffix)"
        
        unaccountedFilePaths.remove(fileName)
        return true
    }
    
    private mutating func checkForLocalizableFile(named name: String, suffix: String, isFolder: Bool = false) -> Bool {
        let fileName = "\(name).\(suffix)"
        let localizedFileNames = localizedFiles(named: fileName)
        guard !localizedFileNames.isEmpty else {
            return false
        }
        
        localizedFileNames.forEach { localizedFileName in
            unaccountedFilePaths.remove(localizedFileName)
            
            if isFolder {
                let localizedFolderName = "\(localizedFileName)/"
                unaccountedFilePaths = unaccountedFilePaths.filter {
                    !$0.hasPrefix(localizedFolderName)
                }
            }
        }
        
        return true
    }
    
    private func localizedFiles(named name: String) -> [String] {
        let pattern = "\\w+.lproj/\(name)"
        return filesByPathInBundle.keys.filter { file in
            if file == name { return true }
            return file.matches(pattern)
        }
    }
    
}

extension FileReporterContext {
    
    var icon: ReportAttachment? {
        let appInfo = self.appInfo
        let iconFileNames = [\AppInfo.bundleIcons, \AppInfo.bundleIconsForIpad]
            .lazy
            .compactMap {
                appInfo.value(for: $0)
            }
            .flatMap {
                $0.primary.files
            }
        let iconURL = iconFileNames
            .lazy
            .compactMap { file in
                self.firstURL {
                    $0.hasPrefix(file) && $0.hasSuffix(".png")
                }
            }
            .first
        return iconURL.map {
            ReportAttachment(name: "Icon.png", source: $0)
        }
    }
    
}

extension FileReporterContext {
    
    func firstURL(matching pattern: (String) -> Bool) -> URL? {
        let key = filesByPathInBundle.keys.lazy.filter(pattern).sorted().first
        return key.flatMap {
            filesByPathInBundle[$0]
        }
    }
    
    private mutating func checkHasFiles(for expectation: String, matching pattern: (String) -> Bool) -> IntegrityCheck.Result {
        
        let filtered = unaccountedFilePaths.filter { file in
            let matches = pattern(file)
            return !matches
        }
        
        guard filtered.count != unaccountedFilePaths.count else {
            return .failed(message: expectation)
        }
        
        unaccountedFilePaths = filtered
        return .passed
    }
    
}
