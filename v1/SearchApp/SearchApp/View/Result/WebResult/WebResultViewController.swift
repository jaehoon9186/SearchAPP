//
//  1ViewController.swift
//  SearchApp
//
//  Created by LeeJaehoon on 2023/12/08.
//

import Foundation
import UIKit
import Combine

protocol WebResultViewControllerDelegate {
    func goErrorView(error: Error)
    func goDetailView(url: String)
}


class WebResultViewController: UIViewController {
    // MARK: - Properties

    var delegate: WebResultViewControllerDelegate?

    private let viewModel = WebResultViewModel()
    private let input: PassthroughSubject<WebResultViewModel.Input, Never> = .init()

    private let resultSubject: PassthroughSubject<WebSearch, Never> = .init()
    private var cancellable = Set<AnyCancellable>()

    private var isEnd: CurrentValueSubject<Bool, Never> = .init(false)

    private var list: [WebResult] = []
    private var nextPage: Int?
    private var searchWord: String?

    private var button: MoreButtonView?

    private let tableView: UITableView = {
        let tableView = UITableView()
//        tableView.backgroundView?.backgroundColor = .white
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

        bind()
        configureUI()
    }

    // MARK: - Actions


    // MARK: - Helpers
    func sendSearchWord(word: String) {
        searchWord = word
        input.send(.webButtonTap(query: searchWord ?? ""))
    }

    private func updateResult(result: WebSearch, nowPage: Int) {
        if nowPage == 1 {
            list = []
        }
        nextPage = nowPage + 1
        resultSubject.send(result)
    }

    private func bind() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                switch output {

                case .fetchFail(error: let error):
                    self?.delegate?.goErrorView(error: error)
                case .fetchWebSucceed(result: let result, nowPage: let nowPage):
                    self?.updateResult(result: result, nowPage: nowPage)
                }
            }
            .store(in: &cancellable)

        resultSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] webSearch in
                self?.isEnd.send(webSearch.meta!.isEnd)
                self?.list += webSearch.webResults!
                self?.tableView.reloadData()
            }
            .store(in: &cancellable)


        isEnd
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnd in
                self?.button?.button.isEnabled = !isEnd
            }
            .store(in: &cancellable)
    }

    private func configureUI() {

        button = MoreButtonView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 100))

        button?.onButtonTap = { [weak self] in
            self?.input.send(.webButtonTap(query: self?.searchWord ?? "", page: self?.nextPage ?? 1))
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
        self.delegate?.goDetailView(url: list[indexPath.row].url)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        list.count
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if let cell = tableView.dequeueReusableCell(withIdentifier: "webTableViewCell", for: indexPath) as? WebTableViewCell {
            cell.title.text = list[indexPath.row].title.decodeHTML
            cell.contents.text = list[indexPath.row].contents.decodeHTML
            cell.date.text = list[indexPath.row].datetime.dateString

            return cell
        }

        return UITableViewCell()
    }

}
