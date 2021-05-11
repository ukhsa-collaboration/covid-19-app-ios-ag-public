//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation

class LocalizableStringDictParser: LocalizableKeys {
    var keys: Set<LocalizableKey> = []
    
    private let file: URL
    
    init(file: URL) throws {
        self.file = file
        
        var propertyListFormat = PropertyListSerialization.PropertyListFormat.xml
        
        guard let plistData = try PropertyListSerialization.propertyList(
            from: Data(contentsOf: file),
            options: .mutableContainersAndLeaves,
            format: &propertyListFormat
        ) as? [String: AnyObject] else {
            throw FileParserError.unableToParse
            
        }
        
        keys = Set<LocalizableKey>(keys: Array(plistData.keys))
    }
    
    func getPlist(withName name: String) -> [String]? {
        if let path = Bundle.main.path(forResource: name, ofType: "plist"),
            let xml = FileManager.default.contents(atPath: path) {
            return (try? PropertyListSerialization.propertyList(from: xml, options: .mutableContainersAndLeaves, format: nil)) as? [String]
        }
        
        return nil
    }
    
}

extension String {
    func deleteSuffix(_ suffix: String) -> String {
        guard hasSuffix(suffix) else { return self }
        return String(dropLast(suffix.count))
    }
}

extension Set where Element == LocalizableKey {
    /// Converts array of keys fro strings/stringsdict file to a Set of LocalizableKey objects
    init(keys: [String]) {
        
        var tmpDict = [String: String?]()
        keys.forEach {
            guard tmpDict[$0] == nil else { return }
            
            if $0.hasSuffix("_wls") {
                tmpDict[$0.deleteSuffix("_wls")] = $0
            } else {
                tmpDict.updateValue(nil, forKey: $0)
            }
        }
        
        self = Set<Element>(tmpDict.map { key, value in
            Element(key: key, keyWithSuffix: value)
        })
    }
}
