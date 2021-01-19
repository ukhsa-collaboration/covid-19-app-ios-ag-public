//
// Copyright © 2020 NHSX. All rights reserved.
//

import UIKit

extension InformationBox {
    public enum Content {
        case title(String)
        case heading(String)
        case boldBody(String)
        case body(String)
        case view(UIView)
        case linkButton(String, UIImage?, () -> Void)
    }
    
    public static func information(color: Style.InformationColor = .darkBlue, _ views: [UIView]) -> InformationBox {
        InformationBox(
            views: views,
            style: .information(color),
            backgroundColor: .clear
        )
    }
    
    public static var information: (
        purple: ([Content]) -> InformationBox,
        orange: ([Content]) -> InformationBox,
        lightBlue: ([Content]) -> InformationBox,
        turquoise: ([Content]) -> InformationBox,
        darkBlue: ([Content]) -> InformationBox,
        pink: ([Content]) -> InformationBox
    ) {
        (
            { .information(color: .purple, $0) },
            { .information(color: .orange, $0) },
            { .information(color: .lightBlue, $0) },
            { .information(color: .turquoise, $0) },
            { .information(color: .darkBlue, $0) },
            { .information(color: .pink, $0) }
        )
        
    }
    
    public static func information(_ text: String) -> InformationBox {
        .information([BaseLabel().styleAsBody().set(text: text)])
    }
    
    public static func information(title: String, body: [String]) -> InformationBox {
        .information([.heading(title)] + body.map { .body($0) })
    }
    
    public static func information(_ content: Content...) -> InformationBox {
        .information(content)
    }
    
    public static func information(color: Style.InformationColor = .darkBlue, _ content: [Content]) -> InformationBox {
        .information(color: color, content.map { content -> UIView in
            switch content {
            case .title(let text):
                return BaseLabel().styleAsTertiaryTitle().set(text: text)
            case .heading(let text):
                return BaseLabel().styleAsHeading().set(text: text)
            case .boldBody(let text):
                return BaseLabel().styleAsBoldBody().set(text: text)
            case .body(let text):
                return BaseLabel().styleAsBody().set(text: text)
            case .view(let view):
                return view
            case .linkButton(let text, let image, let action):
                return LinkButton(title: text, accessoryImage: image, action: action)
            }
        })
    }
}
