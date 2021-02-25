//
// Copyright © 2021 DHSC. All rights reserved.
//

import BehaviourModels
import SwiftUI
import UIKit

extension UIView {
    func asPNG(bounds: CGRect) -> Data {
        let renderer = UIGraphicsImageRenderer(size: bounds.size)
        return renderer.pngData { rendererContext in
            rendererContext.cgContext.translateBy(x: bounds.width / 2, y: bounds.height / 2) // translate otherwise it draws the image center at the origin
            layer.render(in: rendererContext.cgContext)
        }
    }
}

class ImageSaver: NSObject, UIDocumentPickerDelegate {
    func save(url: URL) {
        let documentsPicker = UIDocumentPickerViewController(url: url, in: .moveToService)
        UIApplication.shared.windows.first?.rootViewController?.present(documentsPicker, animated: true)
    }
}

// https://stackoverflow.com/questions/57200521/how-to-convert-a-view-not-uiview-to-an-image
struct BoundsReader: View {
    @Binding var bounds: CGRect
    
    var body: some View {
        GeometryReader { proxy in
            self.createView(proxy: proxy)
        }
    }
    
    func createView(proxy: GeometryProxy) -> some View {
        DispatchQueue.main.async {
            self.bounds = proxy.frame(in: .local)
        }
        return Rectangle().fill(Color.clear)
    }
}

struct RulesView: View {
    let rules: [IsolationModel.Rule]
    var body: some View {
        ForEach(rules, id: \.description) { rule in
            RuleView(rule: rule)
                .padding()
                .previewLayout(.sizeThatFits)
        }
        .background(Color(UIColor.systemBackground))
    }
}

struct StatesView: View {
    let collection: [BehaviourModels.StateCollection]
    var body: some View {
        ForEach(collection) { state in
            StateView(collection: state)
                .padding()
                .previewLayout(.sizeThatFits)
        }
    }
}

struct CaptureView<Content: View>: View {
    let content: Content
    @State private var bounds: CGRect = .zero
    private let saver = ImageSaver()
    var body: some View {
        content
            .contextMenu(menuItems: {
                Button {
                    self.saveImage()
                } label: {
                    Text("Save Image...")
                }
            })
            .background(BoundsReader(bounds: $bounds))
    }
    
    private func saveImage() {
        
        guard !bounds.isEmpty else {
            print("empty bounds")
            return
        }
        
        let host = UIHostingController(rootView: content)
        host.view.drawHierarchy(in: bounds, afterScreenUpdates: true)
        let imageData = host.view.asPNG(bounds: bounds)
        do {
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("image.png")
            try imageData.write(to: url)
            saver.save(url: url)
        } catch {
            print("\(error)")
        }
    }
}

struct ContentView: View {
    var body: some View {
        ScrollView {
            CaptureView(content: RulesView(rules: IsolationModelCurrentRuleSet.rulesRespondingToExternalEvents))
            Divider()
            CaptureView(content: RulesView(rules: IsolationModelCurrentRuleSet.rulesAutomaticallyTriggeredOverTime))
            Divider()
            CaptureView(content: RulesView(rules: IsolationModelCurrentRuleSet.fillerRules))
            Divider()
            CaptureView(content: StatesView(collection: IsolationModelCurrentRuleSet.unreachableStateCollections))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
