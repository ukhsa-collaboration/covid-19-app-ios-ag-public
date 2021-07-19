//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Domain
import Foundation
import Interface
import UIKit

class LogsViewController: UIViewController {
    
    private var cancellables = [AnyCancellable]()
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.textColor = UIColor(.primaryText)
        view = textView
        return textView
    }()
    
    private var text = "" {
        didSet {
            textView.text = text
            textView.flashScrollIndicators()
        }
    }
    
    private var autoScrollEnabled = true {
        didSet {
            updateAutoscrollButtons()
        }
    }
    
    private var logs: InterfaceProperty<String>
    
    init(loggingManager: LoggingManager) {
        logs = loggingManager.$logs
            .debounce(for: .seconds(0.1), scheduler: RunLoop.main)
            .property(initialValue: "")
        
        super.init(nibName: nil, bundle: nil)
        
        title = "Logs"
        tabBarItem.image = UIImage(systemName: "note.text")
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "square.and.arrow.up"),
            style: .plain,
            target: self,
            action: #selector(share)
        )
        updateAutoscrollButtons()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        let textView = self.textView
        view = textView
        
        logs.sink { [weak self] text in
            self?.text = text
        }
    }
    
    @objc private func share() {
        let fileManager = FileManager()
        guard
            let logsFolder = try? fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("Logs"),
            fileManager.fileExists(atPath: logsFolder.path) else {
            let viewController = UIAlertController(title: "No data to share yet", message: nil, preferredStyle: .alert)
            viewController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(viewController, animated: true, completion: nil)
            return
        }
        let viewController = UIActivityViewController(activityItems: [logsFolder], applicationActivities: nil)
        present(viewController, animated: true, completion: nil)
    }
    
    @objc private func toggleAutoscroll() {
        autoScrollEnabled.toggle()
    }
    
    private func updateAutoscrollButtons() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: autoScrollEnabled ? "Auto scroll enabled" : "Auto scroll disabled",
            style: .plain,
            target: self,
            action: #selector(toggleAutoscroll)
        )
    }
    
    private func contentSizeDidChange() {
        guard autoScrollEnabled else { return }
        let textView = self.textView
        var contentOffset = textView.contentOffset
        contentOffset.y = max(-textView.adjustedContentInset.top, textView.contentSize.height - textView.frame.height + textView.adjustedContentInset.bottom)
        DispatchQueue.main.async {
            textView.setContentOffset(contentOffset, animated: false)
        }
    }
}
