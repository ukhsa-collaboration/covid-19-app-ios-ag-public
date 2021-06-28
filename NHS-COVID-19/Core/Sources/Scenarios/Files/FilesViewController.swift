//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Domain
import Foundation
import Interface
import UIKit

private struct File {
    let url: URL
    var name: String {
        Self.name(atPath: url.path)
    }
    
    var isDirectory: Bool {
        var isDirectory: ObjCBool = false
        FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)
        return isDirectory.boolValue
    }
    
    static func name(atPath path: String) -> String {
        FileManager.default.displayName(atPath: path)
    }
    
    static var documents: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    static func contents(of url: URL) -> [File] {
        let contents = try? FileManager.default.contentsOfDirectory(atPath: url.path)
        return contents?.compactMap {
            File(url: url.appendingPathComponent($0))
        } ?? []
    }
}

class FilesViewController: UITableViewController {
    
    private let root: URL
    private var files: [File] = [File]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    init(root: URL? = nil) {
        
        if let root = root {
            self.root = root
        } else {
            self.root = File.documents
        }
        
        super.init(nibName: nil, bundle: nil)
        
        if let root = root {
            title = File.name(atPath: root.path)
        } else {
            title = "Files"
        }
        tabBarItem.image = UIImage(systemName: "doc.text.magnifyingglass")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        scan()
    }
    
    private func scan() {
        files = File.contents(of: root)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class FilesContentsController: UIViewController {
    private let root: URL
    private var content: String? {
        didSet {
            textView.text = content
        }
    }
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.textColor = UIColor(.primaryText)
        view = textView
        return textView
    }()
    
    init(root: URL) {
        self.root = root
        super.init(nibName: nil, bundle: nil)
        title = File.name(atPath: root.path)
        unpack()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "square.and.arrow.up"),
            style: .plain,
            target: self,
            action: #selector(share)
        )
    }
    
    override func loadView() {
        super.loadView()
        view = textView
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func unpack() {
        if let data = try? Data(contentsOf: root) {
            let display = String(data: data, encoding: .utf8)
            if let display = display {
                content = display
            } else if let title = title {
                let parent = root.deletingLastPathComponent().lastPathComponent // assuming that the name of the parent folder is the environment
                if let contents = EncryptedStore(service: parent).dataEncryptor(title).wrappedValue {
                    content = String(data: contents, encoding: .utf8)
                    self.title = title + " \u{1F512}"
                }
            }
        }
    }
    
    @objc private func share() {
        guard let content = content else {
            let alert = UIAlertController(title: "No data to share", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        let activityVC = UIActivityViewController(activityItems: [content], applicationActivities: nil)
        present(activityVC, animated: true)
    }
}

extension FilesViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        files.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "file")
        cell.textLabel?.text = files[indexPath.row].name
        cell.accessoryType = files[indexPath.row].isDirectory ? .disclosureIndicator : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if files[indexPath.row].isDirectory {
            navigationController?.pushViewController(FilesViewController(root: files[indexPath.row].url), animated: true)
        } else {
            navigationController?.pushViewController(FilesContentsController(root: files[indexPath.row].url), animated: true)
        }
    }
}
