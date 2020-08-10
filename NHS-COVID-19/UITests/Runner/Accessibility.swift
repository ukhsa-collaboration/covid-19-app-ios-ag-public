//
// Copyright © 2020 NHSX. All rights reserved.
//

import TestSupport
import UIKit
import XCTest

struct AccessibilityElement: Equatable, Encodable {
    var label: String?
    var traits = UIAccessibilityTraits.none
}

enum AccessibilityNode: Equatable {
    case container(children: [AccessibilityNode])
    case element(AccessibilityElement)
    
    static func element(configure: (inout AccessibilityElement) -> Void) -> AccessibilityNode {
        var element = AccessibilityElement()
        configure(&element)
        return .element(element)
    }
}

extension AccessibilityNode: CustomDescriptionConvertible {
    
    var descriptionObject: Description {
        switch self {
        case .container(let children):
            return .array(children.map { $0.descriptionObject })
        case .element(let element):
            return .encodable(element)
        }
    }
    
}

extension UIView {
    
    var accessibilitySnapshot: AccessibilityNode {
        if shouldTreatAsAccessibilityElement {
            return .element {
                $0.label = accessibilityLabel
                $0.traits = accessibilityTraits
            }
        } else {
            let children = subviews.lazy
                .map { $0.accessibilitySnapshot }
                .flatMap { $0.nodes }
            return .container(children: Array(children))
        }
    }
    
    private var shouldTreatAsAccessibilityElement: Bool {
        isAccessibilityElement || (accessibilityLabel != nil)
    }
    
}

private extension AccessibilityNode {
    
    var nodes: [AccessibilityNode] {
        switch self {
        case .container(let children):
            return children
        case .element:
            return [self]
        }
    }
    
}

extension UIAccessibilityTraits: Encodable {
    public func encode(to encoder: Encoder) throws {
        let strings = Self.knownTraits.compactMap { (trait, value) -> String? in
            contains(trait) ? value : nil
        }
        try strings.encode(to: encoder)
    }
}

extension UIAccessibilityTraits {
    public static var knownTraits: [UIAccessibilityTraits: String] {
        [
            .button: "button",
            .link: "link",
            .header: "header",
            .searchField: "searchField",
            .image: "image",
            .selected: "selected",
            .playsSound: "playsSound",
            .keyboardKey: "keyboardKey",
            .staticText: "staticText",
            .summaryElement: "summaryElement",
            .notEnabled: "notEnabled",
            .updatesFrequently: "updatesFrequently",
            .startsMediaSession: "startsMediaSession",
            .adjustable: "adjustable",
            .allowsDirectInteraction: "allowsDirectInteraction",
            .causesPageTurn: "causesPageTurn",
            .tabBar: "tabBar",
        ]
    }
}

func XCTAssertAccessibility(_ viewController: UIViewController, _ children: [AccessibilityNode], file: StaticString = #file, line: UInt = #line) {
    TS.assert(viewController.view.accessibilitySnapshot, equals: .container(children: children), file: file, line: line)
}
