//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import SwiftUI

public struct IsolatingIndicator: View {
    
    @State private var animate = false
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    private var isDetectionPaused: Bool
    private let remainingDays: Int
    private let date: Date
    private let percentRemaining: Double
    
    fileprivate init(remainingDays: Int, percentRemaining: Double, date: Date, isDetectionPaused: Bool) {
        self.remainingDays = remainingDays
        self.date = date
        self.isDetectionPaused = isDetectionPaused
        self.percentRemaining = percentRemaining
    }
    
    private func pulsatingCircle(delay: Double) -> some View {
        Circle()
            .foregroundColor(Color(.errorRed))
            .scaleEffect(animate ? 4 : 0)
            .opacity(Double(animate ? 0 : 1))
            .animation(
                Animation.easeOut(duration: 3)
                    .repeatForever(autoreverses: false).delay(delay)
            )
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
    
    public var body: some View {
        VStack(alignment: .center, spacing: .standardSpacing) {
            Text(verbatim: localize(.isolation_until_date_title))
                .font(.title)
                .bold()
                .foregroundColor(Color(.primaryText))
                .fixedSize(horizontal: false, vertical: true)
            
            Text(verbatim: localize(.isolation_until_date(date: date)))
                .font(.headline)
                .foregroundColor(Color(.primaryText))
                .fixedSize(horizontal: false, vertical: true)
            
            ZStack(alignment: .center) {
                if self.reduceMotion || isDetectionPaused {
                    Circle()
                        .foregroundColor(Color(.errorRed))
                        .opacity(0.05).onAppear {
                            self.animate = false
                        }
                } else {
                    self.pulsatingCircle(delay: 0).onAppear {
                        if !self.animate {
                            self.animate = true
                        }
                    }
                    self.pulsatingCircle(delay: 1)
                }
                
                Arc(percent: 1).foregroundColor(Color(.background))
                Arc(percent: self.percentRemaining).foregroundColor(Color(.errorRed))
                
                Text("\(remainingDays)")
                    .font(Font(UIFont.boldSystemFont(ofSize: 48)))
                    .foregroundColor(Color(.background))
                    .padding(30)
                    .background(Color(.errorRed))
                    .clipShape(Circle())
                    .fixedSize()
                    .padding(10)
            }
            .frame(width: 110, height: 110, alignment: .center)
            .padding(.standardSpacing)
            .zIndex(-1)
            
            Text(verbatim: localize(.isolation_days_subtitle(days: remainingDays)))
                .font(.headline)
                .foregroundColor(Color(.primaryText))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(EdgeInsets(top: .bigSpacing, leading: 0, bottom: .tripleSpacing, trailing: 0))
        .accessibilityElement(children: .ignore)
        .accessibility(label: Text(accessibilityLabel))
        .accessibility(addTraits: .isStaticText)
    }
    
    private var accessibilityLabel: String {
        localize(.isolation_indicator_accessiblity_label(date: date, days: remainingDays))
    }
}

extension RiskLevelIndicator {
    static func makeIsolatingIndicator(days: Int, percentRemaining: Double, date: Date, isDetectionPaused: Bool) -> AnyView {
        AnyView(IsolatingIndicator(remainingDays: days, percentRemaining: percentRemaining, date: date, isDetectionPaused: isDetectionPaused))
    }
}
