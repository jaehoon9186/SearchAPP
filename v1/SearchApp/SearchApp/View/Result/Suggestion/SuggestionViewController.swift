//
//  SuggestionViewController.swift
//  SearchApp
//
//  Created by LeeJaehoon on 2023/12/15.
//

import UIKit
import Combine

protocol SuggestionViewControllerDelegate {
    func updateSearchBar(word: String)
    func goErrorView(error: Error)
}

class SuggestionViewController: UIViewController {

    // MARK: - Properties
    var delegate: SuggestionViewControllerDelegate?
    var viewModel: SuggestionViewModel!

    private var cancellable = Set<AnyCancellable>()
    // input
    private let removeRecordSubject: PassthroughSubject<SearchRecord, Never> = .init()
    private let searchWordSubject: PassthroughSubject<String, Never> = .init()

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

        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .onDrag

//        bind()
        configureUI()
    }

    // superview에서 유동적으로 자식클래스를 추가 제거 한다면 viewdidload로 옮겨도 ㄱㅊ을듯.
    override func viewDidAppear(_ animated: Bool) {
        bind()
    }

    // MARK: - Actions

    // MARK: - Helpers
    private func bind() {
        let input = SuggestionViewModel.Input(
            searchWord: searchWordSubject.eraseToAnyPublisher(),
            recordRemoveButtonTap: removeRecordSubject.eraseToAnyPublisher())

        let output = viewModel.transform(input: input)

        output.fetchFail
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.delegate?.goErrorView(error: error)
            }.store(in: &cancellable)

        output.updateUI
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }.store(in: &cancellable)

        if let parentView = parent as? SearchViewController {
            parentView.temporarySearchWord
                .debounce(for: 0.5, scheduler: RunLoop.main)
                .sink { [weak self] searchBarWord in
                    self?.searchWordSubject.send(searchBarWord)
                }.store(in: &cancellable)
        } else {
            print("DEBUG: didn't find parent class")
        }
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
            self.delegate?.updateSearchBar(word: viewModel.records[indexPath.row].word!)
        } else {
            self.delegate?.updateSearchBar(word: viewModel.suggestion.suggestedWords[indexPath.row])
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return viewModel.records.count
        } else {
            return viewModel.suggestion.suggestedWords.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "recordCell", for: indexPath) as! RecordTableViewCell
            cell.onTapDeleteButton = { [weak self] in
                if let record = self?.viewModel.records[indexPath.row] {
                    self?.removeRecordSubject.send(record)
                }
            }
            cell.word.text = viewModel.records[indexPath.row].word!
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "suggestionCell", for: indexPath) as! SuggestionTableViewCell
            cell.word.text = viewModel.suggestion.suggestedWords[indexPath.row]
            return cell
        }
    }
}
