//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

@available(iOS 13.0, *)
class DeviceManager: ObservableObject {

    static let shared = DeviceManager()

    var deviceName: String {
        get {
            UserDefaults.standard.string(forKey: "deviceName") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "deviceName")
        }
    }

    var experimentName: String {
        get {
            UserDefaults.standard.string(forKey: "experimentName") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "experimentName")
        }
    }

    var isConfigured: Bool {
        !deviceName.isEmpty && !experimentName.isEmpty
    }

}
