//
// Copyright © 2022 DHSC. All rights reserved.
//

import Foundation

public class NewLabelState: ObservableObject {
    private var newLabelForName: String

    public final var setByCoordinator: Bool

    @Published public var shouldNotShowNewLabel: Bool {
        didSet {
            UserDefaults.standard.set(shouldNotShowNewLabel, forKey: newLabelForName)
        }
    }

    public init(newLabelForName: String = "",
                setByCoordinator: Bool = false) {
        self.newLabelForName = newLabelForName
        self.setByCoordinator = setByCoordinator
        self.shouldNotShowNewLabel = UserDefaults.standard.bool(forKey: newLabelForName)
    }
}
