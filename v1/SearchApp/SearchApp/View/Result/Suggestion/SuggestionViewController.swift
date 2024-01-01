//
//  SuggestionViewController.swift
//  SearchApp
//
//  Created by LeeJaehoon on 2023/12/15.
//

import UIKit

class SuggestionViewController: UIViewController {

    // MARK: - Properties

    private var records: [SearchRecord] = []
    private var suggestions: [String] = []

    private let tableView: UITableView = {
        let tableView = UITableView()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell1")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell2")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .systemPink

        tableView.delegate = self
        tableView.dataSource = self

        configureUI()
    }

    // MARK: - Actions

    // MARK: - Helpers
    func updateResult<T: Any>(result: T) {
        if let updated = result as? [SearchRecord] {
            records = updated
        } else if let updated = result as? Suggestion {
            suggestions = updated.suggestedWords
        }

        tableView.reloadData()
    }


    private func configureUI() {

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

extension SuggestionViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return records.count
        } else {
            return suggestions.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath)
            cell.textLabel?.text = records[indexPath.row].word!
            cell.backgroundColor = .blue
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell2", for: indexPath)
            cell.textLabel?.text = suggestions[indexPath.row]
            cell.backgroundColor = .systemPink
            return cell
        }
    }
}
