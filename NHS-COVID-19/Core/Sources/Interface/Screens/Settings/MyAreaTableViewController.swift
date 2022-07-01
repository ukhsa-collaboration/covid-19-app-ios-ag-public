//
// Copyright © 2021 DHSC. All rights reserved.
//

import Localization
import UIKit

public protocol MyAreaViewControllerInteracting {
    func didTapEditPostcode() -> Void
}

public class MyAreaTableViewController: UITableViewController {

    struct Row {
        let label: String
        let value: InterfaceProperty<String?>
    }

    public typealias Interacting = MyAreaViewControllerInteracting

    // MARK: - Properties

    private let viewModel: ViewModel
    private let interactor: Interacting
    private let rows: [Row]

    // MARK: - Constructors

    public init(viewModel: ViewModel, interactor: Interacting) {
        self.viewModel = viewModel
        self.interactor = interactor

        rows = [
            Row(label: localize(.my_area_postcode_disctrict), value: viewModel.$postcode),
            Row(label: localize(.my_area_local_authority), value: viewModel.$localAuthority),
        ]
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View's life cycle

    override public func viewDidLoad() {
        super.viewDidLoad()
        title = localize(.my_area_title)
        view.styleAsScreenBackground(with: traitCollection)
        tableView.allowsSelection = false
        setupUI()
    }

    // MARK: - UI elements

    private func setupUI() {
        // Add edit button in the navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: localize(.my_area_edit_button_title),
            style: .plain,
            target: self,
            action: #selector(editTapped)
        )

        // Hides separator lines on empty rows
        tableView.tableFooterView = UIView()
    }

    // MARK: - Helper methods

    @objc private func editTapped() {
        interactor.didTapEditPostcode()
    }

}

// MARK: - View model

extension MyAreaTableViewController {
    public struct ViewModel {
        @InterfaceProperty
        var postcode: String?
        @InterfaceProperty
        var localAuthority: String?

        public init(postcode: InterfaceProperty<String?>, localAuthority: InterfaceProperty<String?>) {
            _postcode = postcode
            _localAuthority = localAuthority
        }
    }
}

// MARK: - UITableViewController methods

extension MyAreaTableViewController {

    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rows.count
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        DetailTableViewCell.create(
            tableView: tableView,
            label: rows[indexPath.row].label,
            value: rows[indexPath.row].value,
            withAccessoryType: false
        )
    }

}
