//
//  1ViewController.swift
//  SearchApp
//
//  Created by LeeJaehoon on 2023/12/08.
//

import Foundation
import UIKit
import Combine

protocol WebResultViewControllerDelegate: AnyObject {
    func goErrorView(error: Error)
    func goDetailView(url: String)
}


class WebResultViewController: UIViewController {
    // MARK: - Properties

    weak var delegate: WebResultViewControllerDelegate?
    var viewModel: WebResultViewModel!

    // input
    let searchWebSubject: CurrentValueSubject<String, Never> = .init("")

    private var cancellable = Set<AnyCancellable>()

    private var button: MoreButtonView?

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(WebTableViewCell.self, forCellReuseIdentifier: "webTableViewCell")
        return tableView
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .blue

        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .onDrag

//        bind()
        configureUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        bind()
    }

    // MARK: - Actions


    // MARK: - Helpers

    private func bind() {
        let input = WebResultViewModel.Input(searchWeb: searchWebSubject.eraseToAnyPublisher())

        let output = viewModel.transform(input: input)

        output.fetchFail
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.delegate?.goErrorView(error: error)
            }
            .store(in: &cancellable)

        output.moreButtonisEnd
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.button?.button.isEnabled = false
            }
            .store(in: &cancellable)

        output.updateUI
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellable)
    }

    private func configureUI() {

        button = MoreButtonView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 100))

        button?.onButtonTap = { [weak self] in
            self?.searchWebSubject.send(self?.searchWebSubject.value ?? "")
        }
        self.tableView.tableFooterView = button

        self.view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension WebResultViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.goDetailView(url: viewModel.webResultList[indexPath.row].url)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.webResultList.count
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if let cell = tableView.dequeueReusableCell(withIdentifier: "webTableViewCell", for: indexPath) as? WebTableViewCell {
            let result = viewModel.webResultList[indexPath.row]
            cell.title.text = result.title.decodeHTML
            cell.contents.text = result.contents.decodeHTML
            cell.date.text = result.datetime.dateString

            return cell
        }

        return UITableViewCell()
    }

}
