//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxParser

private class LocalizationFuncVisitor: SyntaxVisitor {

    private(set) var usedKeys: Set<String> = []

    private let definedKeys: Set<String>

    init(definedKeys: Set<String>) {
        self.definedKeys = definedKeys
        super.init()
    }

    override func visit(_ token: TokenSyntax) -> SyntaxVisitorContinueKind {
        guard let prefixPeriodToken = token.tokens.first(where: { $0.tokenKind == .prefixPeriod }
        ) else { return .visitChildren }

        guard case let .identifier(argName) = prefixPeriodToken.nextToken?.tokenKind, definedKeys.contains(argName) else { return .visitChildren }

        usedKeys.insert(argName)

        return .visitChildren
    }
}

/// Checks to see if defined keys are called in this file
struct LocalizableKeysCalledFileParser: UsedLocalizationKeys {
    var keys: Set<String> = []

    private let visitor: LocalizationFuncVisitor

    init(
        files: [URL],
        definedKeys: Set<String>
    ) throws {
        visitor = LocalizationFuncVisitor(definedKeys: definedKeys)
        try files.forEach {
            guard $0.lastPathComponent != "StringLocalizableKey.swift" else {
                return
            }

            let tree = try SyntaxParser.parse($0)
            visitor.walk(tree)
            keys = keys.union(visitor.usedKeys)
        }

    }

    init(source: [String], definedKeys: Set<String>) throws {
        visitor = LocalizationFuncVisitor(definedKeys: definedKeys)

        try source.forEach {
            let tree = try SyntaxParser.parse(source: $0)
            visitor.walk(tree)
            keys = keys.union(visitor.usedKeys)
        }

    }
}
