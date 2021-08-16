//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation
import Localization

class LokaliseOverrider: LocalizationOverrider {
    
    private let lokaliseBundle: Bundle?
    private var languageBundles: [String: Bundle] = [:]
    private let queue = DispatchQueue(label: "LokaliseOverrider")
    
    private static func lookupLokaliseBundle() -> Bundle? {
        let lokaliseURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first?.appendingPathComponent("Lokalise")
        if let path = lokaliseURL?.path,
            let contents = try? FileManager.default.contentsOfDirectory(atPath: path) {
            let urls = contents.compactMap { lokaliseURL?.appendingPathComponent($0) }
            let bundleURL = urls.filter { url in
                url.pathExtension == "bundle" && !url.lastPathComponent.hasPrefix("tmp")
            }.first // todo; if there are multiple bundles we'll need to do something like look at creation dates, etc
            if let bundleURL = bundleURL {
                return Bundle(url: bundleURL)
            }
        }
        return nil
    }
    
    init() {
        lokaliseBundle = Self.lookupLokaliseBundle()
    }
    
    private func languageBundle(for language: String) -> Bundle? {
        queue.sync {
            // todo; when the user updates strings we advise them to restart the app to clear any in-memory state,
            // should that change we should clear this cache when the Lokalise bundle is updated
            if let cachedBundle = languageBundles[language] {
                return cachedBundle
            }
            if let languageBundle = lokaliseBundle?.localizedBundle(for: language) {
                languageBundles[language] = languageBundle
            }
            return languageBundles[language]
        }
    }
    
    func localize(_ key: String, languageCode: String, tableName: String?, bundle: Bundle, value: String, comment: String) -> String? {
        
        // if this flag is set we just return the key
        if MockDataProvider.shared.lokaliseShowKeysOnly {
            return key
        }
        
        // if there is a downloaded Lokalise bundle, use that
        if MockDataProvider.shared.lokaliseShowDownloadedStrings, let lokaliseBundle = lokaliseBundle {
            
            // if we have a non-en language code, point at the specific language bundle
            let actualBundle: Bundle = {
                if languageCode != "en",
                    let languageBundle = languageBundle(for: languageCode) {
                    return languageBundle
                }
                return lokaliseBundle
            }()
            
            let result = NSLocalizedString(key, tableName: tableName, bundle: actualBundle, value: value, comment: "")
            return result
        }
        
        // otherwise there's no override, let normal handling proceed
        return nil
    }
}
