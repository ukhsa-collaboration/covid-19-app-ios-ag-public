//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation
import SwiftUI

struct PulsatingCircle: View {
    let delay: Double
    let initialDiameter: CGFloat
    let color: Color
    
    @State private var animationProgress: Bool = false
    
    private var scale: CGFloat {
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
                DispatchQueue.main.async {
                    self.animationProgress = true
                }
            }
    }
}
