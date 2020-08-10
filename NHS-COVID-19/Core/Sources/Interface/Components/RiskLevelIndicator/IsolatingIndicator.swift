//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import SwiftUI

public struct IsolatingIndicator: View {
    
    @State private var animate = false
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    private var isDetectionPaused: Bool
    private let days: Int
    private let date: Date
    
    fileprivate init(days: Int, date: Date, isDetectionPaused: Bool) {
        self.days = days
        self.date = date
        self.isDetectionPaused = isDetectionPaused
    }
    
    private func pulsatingCircle(delay: Double) -> some View {
        Circle()
            .foregroundColor(Color(.errorRed))
            .scaleEffect(animate ? 5 : 0)
            .opacity(Double(animate ? 0 : 1))
            .animation(
                Animation.easeOut(duration: 3)
                    .repeatForever(autoreverses: false).delay(delay)
            )
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
                
                Text("\(days)")
                    .font(Font(UIFont.boldSystemFont(ofSize: 48)))
                    .foregroundColor(Color(.white))
                    .padding(30)
                    .background(Color(.errorRed))
                    .clipShape(Circle())
                    .fixedSize()
            }
            .frame(width: 100, height: 100, alignment: .center)
            .padding(.standardSpacing)
            .zIndex(-1)
            
            Text(verbatim: localize(.isolation_days_subtitle(days: days)))
                .font(.headline)
                .foregroundColor(Color(.primaryText))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(height: .appActivityIndicatorMinHeight)
        .padding(EdgeInsets(top: .bigSpacing, leading: 0, bottom: .tripleSpacing, trailing: 0))
        .accessibilityElement(children: .ignore)
        .accessibility(label: Text(accessibilityLabel))
    }
    
    private var accessibilityLabel: String {
        localize(.isolation_indicator_accessiblity_label(date: date, days: days))
    }
}

extension RiskLevelIndicator {
    static func makeIsolatingIndicator(days: Int, date: Date, isDetectionPaused: Bool) -> AnyView {
        AnyView(IsolatingIndicator(days: days, date: date, isDetectionPaused: isDetectionPaused))
    }
}
