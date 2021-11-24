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

// https://www.hackingwithswift.com/quick-start/swiftui/how-to-convert-a-swiftui-view-to-an-image
extension View {
    func viewPngData() -> Data {
        let controller = UIHostingController(rootView: self)
        let view = controller.view
        
        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        
        return renderer.pngData(actions: { rendererContext in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
            view?.layer.render(in: rendererContext.cgContext)
        })
    }
}

class ImageSaver: NSObject, UIDocumentPickerDelegate {
    func save(url: URL) {
        let documentsPicker = UIDocumentPickerViewController(url: url, in: .moveToService)
        UIApplication.shared.windows.first?.rootViewController?.present(documentsPicker, animated: true)
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
        
    }
    
    private func saveImage() {
        
        let imageData = viewPngData()
        do {
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("image.png")
            try imageData.write(to: url)
            saver.save(url: url)
        } catch {
            print("CaptureView SaveImage: \(error)")
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
