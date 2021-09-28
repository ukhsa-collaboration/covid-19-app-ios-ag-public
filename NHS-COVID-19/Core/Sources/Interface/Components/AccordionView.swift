//
// Copyright © 2021 DHSC. All rights reserved.
//

import Localization
import SwiftUI
import UIKit

// MARK: - Accordion Group

public struct AccordionGroup<Content>: View where Content: View {
    
    private let title: String
    private let content: () -> Content
    
    public init(_ title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: .standardSpacing) {
            Text(title)
                .styleAsSecondaryHeading()
                .fixedSize(horizontal: false, vertical: true)
            content()
        }
    }
    
}

// MARK: - Accordion View

public enum AccordionViewDisplayMode {
    case singleWithChevron
    case multipleWithPlusMinus
    
    var expandedImageName: ImageName {
        switch self {
        case .singleWithChevron:
            return .accordionExpandedIcon
        case .multipleWithPlusMinus:
            return .accordionMinusIcon
        }
    }
    
    var collapsedImageName: ImageName {
        switch self {
        case .singleWithChevron:
            return .accordionCollapsedIcon
        case .multipleWithPlusMinus:
            return .accordionPlusIcon
        }
    }
}

public struct AccordionView<Content>: View where Content: View {
    private let text: String
    private let content: () -> Content
    private let displayMode: AccordionViewDisplayMode
    @State private var isExpanded: Bool = false
    private var onSizeChanged: ((CGSize) -> Void)?
    
    public mutating func onSizeChanged(_ perform: @escaping (CGSize) -> Void) {
        onSizeChanged = perform
    }
    
    public init(_ text: String,
                displayMode: AccordionViewDisplayMode = .multipleWithPlusMinus,
                @ViewBuilder content: @escaping () -> Content) {
        self.text = text
        self.displayMode = displayMode
        self.content = content
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            Button(
                action: {
                    isExpanded.toggle()
                },
                label: {
                    HStack(alignment: .firstTextBaseline, spacing: .iconTrailingSpacing) {
                        Image(isExpanded
                            ? displayMode.expandedImageName
                            : displayMode.collapsedImageName)
                            .renderingMode(.original)
                            .resizable()
                            .frame(width: .iconSide, height: .iconSide)
                            .textBaselineAligned(font: .headline)
                        Text(text)
                            .foregroundColor(Color(.nhsBlue))
                            .styleAsHeading()
                            .accessibility(removeTraits: .isHeader)
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            )
            .accessibility(
                value: Text(
                    isExpanded
                        ? localize(.accordion_expanded_accessibility_value)
                        : localize(.accordion_collapsed_accessibility_value)
                )
            )
            .accessibility(
                hint: Text(
                    isExpanded
                        ? localize(.accordion_expanded_accessibility_hint)
                        : localize(.accordion_collapsed_accessibility_hint)
                )
            )
            
            if isExpanded {
                Spacer(minLength: .standardSpacing)
                    .fixedSize()
                content()
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, .iconSide + .iconTrailingSpacing)
            }
        }
        .onSizeChanged { onSizeChanged?($0) }
    }
    
}

// MARK: - Private extensions

private extension CGFloat {
    static let iconSide: CGFloat = 27
    static let iconTrailingSpacing: CGFloat = .halfSpacing
}
