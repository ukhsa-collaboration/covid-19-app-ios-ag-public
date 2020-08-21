//
// Copyright © 2020 NHSX. All rights reserved.
//

import ExposureNotification
import Localization
import UIKit

class KeysViewController: ListViewController {
    
    private let keys: [ENTemporaryExposureKey]
    
    init(keys: [ENTemporaryExposureKey]) {
        self.keys = keys
        let rows = keys
            .map { $0.keyData }
            .map { data in
                ListRow(title: "\(data.emoji) \(data.base64EncodedString())") {
                    UIPasteboard.general.string = data.base64EncodedString()
                }
            }
        let keysSection = ListSection(title: "keys (Select to copy)", rows: rows)
        super.init(title: "Keys", sections: [keysSection])
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: localize(.cancel),
            style: .done,
            target: self,
            action: #selector(cancel)
        )
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "square.and.arrow.up"),
            style: .plain,
            target: self,
            action: #selector(share)
        )
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func share() {
        let tempFolder = try! FileManager().url(for: .itemReplacementDirectory, in: .userDomainMask, appropriateFor: Bundle.main.bundleURL, create: true)
        let file = tempFolder.appendingPathComponent("keys.json")
        
        let keys = self.keys.map {
            ExposureKey(
                keyData: $0.keyData,
                rollingPeriod: $0.rollingPeriod,
                rollingStartNumber: $0.rollingStartNumber,
                transmissionRiskLevel: 7
            )
        }
        
        try! JSONEncoder().encode(keys).write(to: file)
        
        let viewController = UIActivityViewController(activityItems: [file], applicationActivities: nil)
        present(viewController, animated: true, completion: nil)
    }
    
    @objc private func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
}
