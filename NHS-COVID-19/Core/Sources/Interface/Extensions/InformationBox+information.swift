//
// Copyright © 2020 NHSX. All rights reserved.
//

import UIKit

extension InformationBox {
    public enum Content {
        case title(String)
        case body(String)
        case view(UIView)
    }
    
    public static func information(_ views: [UIView]) -> InformationBox {
        InformationBox(
            views: views,
            style: .information,
            backgroundColor: .clear
        )
    }
    
    public static func information(_ text: String) -> InformationBox {
        .information([UILabel().styleAsBody().set(text: text)])
    }
    
    public static func information(title: String, body: [String]) -> InformationBox {
        .information([.title(title)] + body.map { .body($0) })
    }
    
    public static func information(_ content: Content...) -> InformationBox {
        .information(content)
    }
    
    public static func information(_ content: [Content]) -> InformationBox {
        .information(content.map { content -> UIView in
            switch content {
            case .title(let text):
                return UILabel().styleAsHeading().set(text: text)
            case .body(let text):
                return UILabel().styleAsBody().set(text: text)
            case .view(let view):
                return view
            }
        })
    }
}
