//
// Copyright © 2020 NHSX. All rights reserved.
//

import UIKit

class RecommendedUpdateManager {

    // MARK: - Properties

    private let notificationCenter: NotificationCenter
    private let enterBackgroundNotification = UIApplication.didEnterBackgroundNotification
    private let enterForegroundNotification = UIApplication.willEnterForegroundNotification
    private let timerScheduler: TimerScheduling
    private var timer: Timer?

    var recommendedUpdateAction: () -> Void

    // MARK: - Init

    init(notificationCenter: NotificationCenter, timerScheduler: TimerScheduling = SystemTimerScheduler(), recommendedUpdateAction: @escaping () -> Void) {
        self.recommendedUpdateAction = recommendedUpdateAction
        self.notificationCenter = notificationCenter
        self.timerScheduler = timerScheduler
        notificationCenter.addObserver(self, selector: #selector(didMoveAppToBackground), name: enterBackgroundNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(didMoveAppToForeground), name: enterForegroundNotification, object: nil)
    }

    deinit {
        notificationCenter.removeObserver(enterBackgroundNotification)
        notificationCenter.removeObserver(enterForegroundNotification)
    }

    // MARK: - Selectors

    @objc func didMoveAppToBackground() {
        timer = timerScheduler.scheduledTimer(withTimeInterval: 300, repeats: false) { [weak self] _ in
            self?.recommendedUpdateAction()
        }
    }

    @objc func didMoveAppToForeground() {
        timer?.invalidate()
    }
}
