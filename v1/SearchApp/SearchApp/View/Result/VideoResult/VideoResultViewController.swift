//
//  VideoResultViewController.swift
//  SearchApp
//
//  Created by LeeJaehoon on 2023/12/15.
//

import UIKit
import Combine

protocol VideoResultViewControllerDelegate {
    func goErrorView(error: Error)
    func goDetailView(url: String)
}

class VideoResultViewController: UIViewController {
    // MARK: - Properties
    var delegate: VideoResultViewControllerDelegate?

    private let viewModel = VideoResultViewModel()
    private let input: PassthroughSubject<VideoResultViewModel.Input, Never> = .init()

    private let resultSubject: PassthroughSubject<VideoSearch, Never> = .init()
    private var cancellable = Set<AnyCancellable>()

    private var isEnd: CurrentValueSubject<Bool, Never> = .init(false)

    private var list: [VideoResult] = []
    private var nextPage: Int?
    private var searchWord: String?

    private var button: MoreButtonView?

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundView?.backgroundColor = .white
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(VideoTableViewCell.self, forCellReuseIdentifier: "videoTableViewCell")
        return tableView
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .green

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
        input.send(.videoButtonTap(query: searchWord ?? ""))
    }

    private func updateResult(result: VideoSearch, nowPage: Int) {
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
                case .fetchVideoSucceed(result: let result, nowPage: let nowPage):
                    self?.updateResult(result: result, nowPage: nowPage)
                }
            }
            .store(in: &cancellable)

        resultSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] VideoSearch in
                self?.isEnd.send(VideoSearch.meta!.isEnd)
                self?.list += VideoSearch.videoResults!
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
            self?.input.send(.videoButtonTap(query: self?.searchWord ?? "", page: self?.nextPage ?? 1))
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


extension VideoResultViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.goDetailView(url: list[indexPath.row].url)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        list.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // dynamic height? 적용할 것
        300
    }

//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
//    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "videoTableViewCell", for: indexPath) as? VideoTableViewCell {

            let time = list[indexPath.row].playTime

            cell.passURL.send(list[indexPath.row].thumbnail)
            cell.playTime.text = "\(time / 60)m \(time % 60)s"
            cell.title.text = list[indexPath.row].title.decodeHTML
            cell.datetime.text = list[indexPath.row].datetime.dateString
        }
        return UITableViewCell()
    }
}

