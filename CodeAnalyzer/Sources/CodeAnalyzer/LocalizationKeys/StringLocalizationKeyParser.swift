//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation
import SwiftSyntax

class LocalizationKeyEnumDeclVisitor: SyntaxVisitor {
    
    struct Enumeration {
        struct Case {
            let name: String
        }
        
        let name: String
        var cases: [Case]
    }
    
    var enums: [EnumDeclSyntax] = []
    
    override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
        enums.append(node)
        return .skipChildren
    }
}

class StringLocalizationKeyParser: DefinedLocalizationKeys {
    private let visitor: LocalizationKeyEnumDeclVisitor
    private let defaultEnumName: String
    private let parameterizedEnumName: String
    
    // MARK: - API
    
    var defaultKeys: Set<String> {
        defaultKeys(enumName: defaultEnumName)
    }
    
    var parameterizedKeys: Set<ParameterizedKey> {
        parameterizedKeys(enumName: parameterizedEnumName)
    }
    
    init(
        file: URL,
        defaultEnumName: String = "StringLocalizationKey",
        parameterizedEnumName: String = "ParameterisedStringLocalizable"
    ) throws {
        visitor = LocalizationKeyEnumDeclVisitor()
        let tree = try SyntaxParser.parse(file)
        visitor.walk(tree)
        
        self.defaultEnumName = defaultEnumName
        self.parameterizedEnumName = parameterizedEnumName
    }
    
    // MARK: - Implementation detail
    
    private func parameterizedKeys(enumName: String) -> Set<ParameterizedKey> {
        guard var targetEnum = visitor.enums.filter({ $0.identifier.text == enumName }).first else {
            return []
        }
        
        // Check if given enum containts an enum Key
        let innerEnums = targetEnum.members.members.compactMap { $0.decl.as(EnumDeclSyntax.self) }
        guard let enumKey = innerEnums.first(where: { $0.identifier.text == "Key" }) else {
            return []
        }
        
        targetEnum = enumKey
        
        let casesForTargetEnum = targetEnum.members.members.compactMap { $0.decl.as(EnumCaseDeclSyntax.self) }
        
        // Get case identifier and it's raw value (second token)
        let keys = casesForTargetEnum.compactMap {
            ParameterizedKey(
                identifier: ($0.elements.first?.identifier.text)!,
                rawValue: ($0.elements.first?.rawValue?.value.tokens.map { $0.text }[1])!
            )
        }
        
        return Set<ParameterizedKey>(keys)
    }
    
    private func defaultKeys(enumName: String) -> Set<String> {
        // Get an enum
        guard let targetEnum = visitor.enums.filter({ $0.identifier.text == enumName }).first else {
            return []
        }
        
        let casesForTargetEnum = targetEnum.members.members.compactMap { $0.decl.as(EnumCaseDeclSyntax.self) }
        
        // Get case identifier
        let keys = casesForTargetEnum.compactMap {
            ($0.elements.first?.identifier.text)!
        }
        
        return Set<String>(keys)
    }
    
}

extension StringLocalizationKeyParser {
    struct ParameterizedKey: Hashable {
        var identifier: String
        var rawValue: String
    }
    
}
