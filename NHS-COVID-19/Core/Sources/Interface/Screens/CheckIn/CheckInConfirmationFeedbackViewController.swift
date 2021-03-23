//
// Copyright © 2021 NHSX. All rights reserved.
//

import Common
import Localization
import UIKit
import AVFoundation
import CoreHaptics

public class CheckInConfirmationFeedbackViewController: UIViewController {
    
    var engine: CHHapticEngine?

    struct Row {
        let title: String
        let subtitle: String?
        let tapped: () -> ()
    }
    private lazy var rows = [
        Row(title: "System 'Success' Haptic", subtitle: "Provided by iOS", tapped: {
            let feedback = UINotificationFeedbackGenerator()
            feedback.notificationOccurred(.success)
        }),
        Row(title: "Custom Haptic", subtitle: "Requires a haptics file to be provided", tapped: {
            guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
                return
            }
            do {
                self.engine = try CHHapticEngine(audioSession: AVAudioSession.sharedInstance())
            } catch let error {
                print("error: \(error)")
            }
            if let engine = self.engine, let url = Bundle.main.url(forResource: "heartbeats", withExtension: "ahap") {
                do {
                    try engine.start()
                    try engine.playPattern(from: url)
                } catch {
                    print("error: \(error)")
                }
            }
        }),
        Row(title: "Custom Sound with System 'Success' Haptic", subtitle: "Requires a sound file to be provided", tapped: {
            if let url = Bundle.main.url(forResource: "success", withExtension: "mp3") {
                var sound: SystemSoundID = 0
                let status = AudioServicesCreateSystemSoundID(url as CFURL, &sound)
                if status == 0 {
                    AudioServicesPlaySystemSoundWithCompletion(sound) {
                        AudioServicesDisposeSystemSoundID(sound)
                    }
                    let feedback = UINotificationFeedbackGenerator()
                    feedback.notificationOccurred(.success)
                }
            }
        }),
        Row(title: "Custom Sound with System 'Alert' Haptic", subtitle: "Requires a sound file to be provided", tapped: {
            if let url = Bundle.main.url(forResource: "success", withExtension: "mp3") {
                var sound: SystemSoundID = 0
                let status = AudioServicesCreateSystemSoundID(url as CFURL, &sound)
                if status == 0 {
                    AudioServicesPlayAlertSoundWithCompletion(sound) {
                        AudioServicesDisposeSystemSoundID(sound)
                    }
                }
            }
        }),
        Row(title: "Custom Sound without Haptic", subtitle: "Requires a sound file to be provided", tapped: {
            if let url = Bundle.main.url(forResource: "success", withExtension: "mp3") {
                var sound: SystemSoundID = 0
                let status = AudioServicesCreateSystemSoundID(url as CFURL, &sound)
                if status == 0 {
                    AudioServicesPlaySystemSoundWithCompletion(sound) {
                        AudioServicesDisposeSystemSoundID(sound)
                    }
                }
            }
        }),
    ]
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "CheckIn Confirmation Feedback"
        
        let tableView = UITableViewController()
        tableView.tableView.dataSource = self
        tableView.tableView.delegate = self
        addFilling(tableView)
    }
}

extension CheckInConfirmationFeedbackViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let subtitle = self.rows[indexPath.row].subtitle {
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
            cell.textLabel?.text = self.rows[indexPath.row].title
            cell.detailTextLabel?.text = subtitle
            return cell
        } else {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
            cell.textLabel?.text = self.rows[indexPath.row].title
            return cell
        }
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.rows.count
    }
}

extension CheckInConfirmationFeedbackViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.rows[indexPath.row].tapped()
    }
}
