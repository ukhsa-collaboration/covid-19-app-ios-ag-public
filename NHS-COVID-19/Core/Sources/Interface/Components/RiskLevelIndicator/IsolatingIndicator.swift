//
// Copyright © 2022 DHSC. All rights reserved.
//

import Localization
import SwiftUI

public struct IsolatingIndicator: View {

    public enum Style {
        case informational
        case warning

        /// - TODO: Refactor this so it's not part of `Style`
        public var baseColor: ColorName {
            switch self {
            case .informational:
                return .scanBlue
            case .warning:
                return .errorRed
            }
        }

        /// - TODO: Refactor this so it's not part of `Style`
        public var title: String {
            switch self {
            case .informational:
                return localize(.be_careful_until_date_title)
            case .warning:
                return localize(.isolation_until_date_title)
            }
        }

        /// - TODO: Refactor this so it's not part of `Style`
        public func accessibilityLabel(date: Date, days: Int) -> String {
            switch self {
            case .informational:
                return localize(.be_careful_indicator_accessibility_label(date: date, days: days))
            case .warning:
                return localize(.isolation_indicator_accessiblity_label(date: date, days: days))
            }
        }
    }

    private var animationDisabled: Bool
    private var isDetectionPaused: Bool
    private let remainingDays: Int
    private let date: Date
    private let percentRemaining: Double
    private let style: Style

    fileprivate init(
        remainingDays: Int,
        percentRemaining: Double,
        date: Date,
        isDetectionPaused: Bool,
        animationDisabled: Bool,
        style: Style
    ) {
        self.remainingDays = remainingDays
        self.date = date
        self.isDetectionPaused = isDetectionPaused
        self.percentRemaining = percentRemaining
        self.animationDisabled = animationDisabled
        self.style = style
    }

    struct Arc: Shape {
        private let percent: Double

        init(percent: Double) {
            self.percent = percent
        }

        func path(in rect: CGRect) -> Path {
            var path = Path()

            let radius = min(rect.width, rect.height) / 2

            path.addArc(
                center: CGPoint(x: rect.midX, y: rect.midY),
                radius: radius,
                startAngle: .degrees(-90),
                endAngle: .degrees(360 * percent - 90),
                clockwise: false
            )

            return path.strokedPath(.init(lineWidth: 5, lineCap: .round))
        }
    }

    private let badgeSize: CGFloat = 110

    /// On iOS 14.0 and 14.1, a bug means returning to the home screen from
    /// the Contact Tracing Hub after turning contact tracing back on causes the
    /// app to crash. This doesn't happen if animation is turned off, so on these
    /// versions, we act as if 'reduce motion' is turned on in Accessibility settings.
    private var shouldDegradeAnimation: Bool {
        if #available(iOS 14.2, *) {
            return false
        } else if #available(iOS 14.0, *) {
            return true
        } else {
            return false
        }
    }

    public var body: some View {

        VStack(alignment: .center, spacing: .standardSpacing) {

            Text(verbatim: style.title)
                .font(.title)
                .bold()
                .foregroundColor(Color(.primaryText))
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)

            Text(verbatim: localize(.isolation_until_date(date: date)))
                .font(.headline)
                .foregroundColor(Color(.primaryText))
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)

            ZStack(alignment: .center) {
                if animationDisabled || isDetectionPaused || shouldDegradeAnimation {
                    Circle()
                        .foregroundColor(Color(style.baseColor))
                        .opacity(0.05)
                } else {
                    PulsatingCircle(delay: 0, initialDiameter: badgeSize, color: Color(style.baseColor))
                    PulsatingCircle(delay: 1, initialDiameter: badgeSize, color: Color(style.baseColor))
                }

                Arc(percent: 1).foregroundColor(Color(.background))
                Arc(percent: self.percentRemaining).foregroundColor(Color(style.baseColor))

                Text(String(remainingDays))
                    .font(Font(UIFont.boldSystemFont(ofSize: 48)))
                    .foregroundColor(Color(.background))
                    .padding(30)
                    .background(Color(style.baseColor))
                    .clipShape(Circle())
                    .fixedSize()
                    .padding(10)
            }
            .frame(width: badgeSize, height: badgeSize, alignment: .center)
            .padding(.standardSpacing)
            .zIndex(-1)
            .background(Group {
                if (animationDisabled || shouldDegradeAnimation) && !isDetectionPaused {
                    Image(.isolatingInformationalCircles)
                }
            })

            Text(verbatim: localize(.isolation_days_subtitle(days: remainingDays)))
                .font(.headline)
                .foregroundColor(Color(.primaryText))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(EdgeInsets(top: .bigSpacing, leading: 0, bottom: .tripleSpacing, trailing: 0))
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibility(label: Text(accessibilityLabel))
        .accessibility(addTraits: .isStaticText)
        .environment(\.locale, Locale(identifier: currentLocaleIdentifier()))
    }

    private var accessibilityLabel: String {
        self.style.accessibilityLabel(date: date, days: remainingDays)
    }
}

extension RiskLevelIndicator {
    static func makeIsolatingIndicator(
        days: Int,
        percentRemaining: Double,
        date: Date,
        isDetectionPaused: Bool,
        animationDisabled: Bool,
        style: IsolatingIndicator.Style
    ) -> AnyView {
        AnyView(
            IsolatingIndicator(
                remainingDays: days,
                percentRemaining: percentRemaining,
                date: date,
                isDetectionPaused: isDetectionPaused,
                animationDisabled: animationDisabled,
                style: style
            )
        )
    }
}
