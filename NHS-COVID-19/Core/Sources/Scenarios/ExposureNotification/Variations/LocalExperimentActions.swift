//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import ExposureNotification
import UIKit

class LocalExperimentActions {
    typealias Row = ExposureNotificationViewController.Row

    private var manager: EnabledExposureManager
    private var device: DeviceManager
    private weak var host: UIViewController?
    private var cancellables = [AnyCancellable]()

    init(manager: EnabledExposureManager, device: DeviceManager, host: UIViewController) {
        self.manager = manager
        self.device = device
        self.host = host
    }

    var rows: [Row] {
        [
            Row(title: "View keys", value: "", action: { self.showKeys(.normal) }),
            Row(title: "View test keys", value: "", action: { self.showKeys(.testing) }),
            Row(title: "Export experiment data", value: "", action: exportExperimentData),
            Row(title: "Detect exposure for experiment", value: "", action: detectExposureForExperiment),
        ]
    }

    private func showKeys(_ mode: EnabledExposureManager.Mode) {
        manager.getDiagnosisKeys(mode: mode) { [weak host] result in
            switch result {
            case .failure(let error):
                let alert = UIAlertController(
                    title: "Failed to get keys",
                    message: error.localizedDescription,
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                host?.present(alert, animated: true, completion: nil)
            case .success(let keys):
                let keysViewController = KeysViewController(keys: keys)
                let navigationController = UINavigationController(rootViewController: keysViewController)
                host?.present(navigationController, animated: true, completion: nil)
            }
        }
    }

    private func exportExperimentData() {
        manager.getDiagnosisKeys(mode: .testing) { [weak host] result in
            switch result {
            case .failure(let error):
                let alert = UIAlertController(
                    title: "Failed to get keys",
                    message: error.localizedDescription,
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                host?.present(alert, animated: true, completion: nil)
            case .success(let keys):
                let payload = ExperimentKeysPayload(keys: keys, deviceManager: self.device)

                let tempFolder = try! FileManager().url(for: .itemReplacementDirectory, in: .userDomainMask, appropriateFor: Bundle.main.bundleURL, create: true)
                let file = tempFolder.appendingPathComponent("\(self.device.experimentName)-\(self.device.deviceName).json")

                let encoder = JSONEncoder()
                encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
                try! encoder.encode(payload).write(to: file)

                let viewController = UIActivityViewController(activityItems: [file], applicationActivities: nil)
                host?.present(viewController, animated: true, completion: nil)
            }
        }
    }

    private func detectExposureForExperiment() {
        let url = URL(string: "https://example.com/path/\(device.experimentName)-collected-keys.json")!
        let cancellable = URLSession.shared
            .dataTaskPublisher(for: url)
            .tryMap { data, response in try JSONDecoder().decode(CollectedExperimentKeysPayload.self, from: data) }
            .print("Server response")
            .flatMap { collectedKeys in
                Publishers.Sequence(sequence: collectedKeys.devices)
            }
            .flatMap { self.manager.exposure(to: $0, configuration: ENExposureConfiguration()) }
            .print("Exposure")
            .collect()
            .map { CollectedExperimentResultsPayload(devices: $0) }
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { [weak host] completion in
                    guard case .failure(let error) = completion else { return }
                    let alert = UIAlertController(
                        title: "Failed to test keys",
                        message: error.localizedDescription,
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    host?.present(alert, animated: true, completion: nil)
                },
                receiveValue: { [weak host] collectedResult in
                    let tempFolder = try! FileManager().url(for: .itemReplacementDirectory, in: .userDomainMask, appropriateFor: Bundle.main.bundleURL, create: true)
                    let file = tempFolder.appendingPathComponent("\(self.device.experimentName)-\(self.device.deviceName)-result.json")

                    let encoder = JSONEncoder()
                    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
                    encoder.dateEncodingStrategy = .iso8601
                    try! encoder.encode(collectedResult).write(to: file)

                    let viewController = UIActivityViewController(activityItems: [file], applicationActivities: nil)
                    host?.present(viewController, animated: true, completion: nil)
                }
            )
        cancellables.append(cancellable)
    }
}
