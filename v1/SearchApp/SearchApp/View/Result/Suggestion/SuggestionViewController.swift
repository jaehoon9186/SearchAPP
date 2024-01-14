//
//  SuggestionViewController.swift
//  SearchApp
//
//  Created by LeeJaehoon on 2023/12/15.
//

import UIKit

protocol SuggestionViewControllerDelegate {
    func deleteRecord(record: SearchRecord)
    func updateSearchBar(word: String)
}

class SuggestionViewController: UIViewController {

    // MARK: - Properties

    var delegate: SuggestionViewControllerDelegate?

    private var records: [SearchRecord] = []
    private var suggestions: [String] = []

    private let tableView: UITableView = {
        let tableView = UITableView()

        tableView.register(RecordTableViewCell.self, forCellReuseIdentifier: "recordCell")
        tableView.register(SuggestionTableViewCell.self, forCellReuseIdentifier: "suggestionCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .systemPink

        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .onDrag

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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            self.delegate?.updateSearchBar(word: records[indexPath.row].word!)
        } else {
            self.delegate?.updateSearchBar(word: suggestions[indexPath.row])
        }
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "recordCell", for: indexPath) as! RecordTableViewCell
            cell.onTapDeleteButton = { [weak self] in
                if let record = self?.records[indexPath.row] {
                    self?.delegate?.deleteRecord(record: record)
                }
            }
            cell.word.text = records[indexPath.row].word!
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "suggestionCell", for: indexPath) as! SuggestionTableViewCell
            cell.word.text = suggestions[indexPath.row]
            return cell
        }
    }
}
