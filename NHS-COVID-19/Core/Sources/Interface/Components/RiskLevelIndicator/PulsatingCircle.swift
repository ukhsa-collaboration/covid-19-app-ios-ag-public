//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
import SwiftUI

struct PulsatingCircle: View {
    let delay: Double
    let initialDiameter: CGFloat
    let color: Color

    var body: some View {
        if #available(iOS 14.0, *) {
            return AnyView(PulsatingCircleIOS14(delay: delay, initialDiameter: initialDiameter, color: color))
        } else {
            return AnyView(PulsatingCircleIOS13(delay: delay, initialDiameter: initialDiameter, color: color))
        }
    }
}

private struct PulsatingCircleIOS14: View {
    @State private var animationProgress: Double = 0

    let delay: Double
    let initialDiameter: CGFloat
    let color: Color

    var scale: CGFloat {
        .indicatorPulseMaxSize / initialDiameter
    }

    private var animation: Animation {
        Animation
            .easeOut(duration: 3)
            .repeatForever(autoreverses: false)
            .delay(delay)
    }

    var body: some View {
        Circle()
            .foregroundColor(color)
            .scaleEffect(scale * CGFloat(animationProgress))
            .opacity(1 - animationProgress)
            .onAppear {
                DispatchQueue.main.async {
                    withAnimation(self.animation) {
                        self.animationProgress = 1
                    }
                }
            }
    }
}

private struct PulsatingCircleIOS13: View {
    @State private var animationProgress: Bool = false

    let delay: Double
    let initialDiameter: CGFloat
    let color: Color

    var scale: CGFloat {
        .indicatorPulseMaxSize / initialDiameter
    }

    private var animation: Animation {
        Animation
            .easeOut(duration: 3)
            .repeatForever(autoreverses: false)
            .delay(delay)
    }

    var body: some View {
        Circle()
            .foregroundColor(color)
            .scaleEffect(scale * CGFloat(animationProgress ? 1 : 0))
            .opacity(animationProgress ? 0 : 1)
            .animation(animation, value: animationProgress)
            .onAppear {
                self.animationProgress = true
            }
    }
}
