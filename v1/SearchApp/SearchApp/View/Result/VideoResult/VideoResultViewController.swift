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

    // input
    let searchVideoSubject: CurrentValueSubject<String, Never> = .init("")

    private var cancellable = Set<AnyCancellable>()

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

        //        bind()
        configureUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        bind()
    }

    // MARK: - Actions


    // MARK: - Helpers
    private func bind() {
        let input = VideoResultViewModel.Input(searchWeb: searchVideoSubject.eraseToAnyPublisher())

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
            self?.searchVideoSubject.send(self?.searchVideoSubject.value ?? "")
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
        self.delegate?.goDetailView(url: viewModel.videoResultList[indexPath.row].url)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.videoResultList.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // dynamic height?
        300
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "videoTableViewCell", for: indexPath) as? VideoTableViewCell {

            let result = viewModel.videoResultList[indexPath.row]

            let time = result.playTime

            cell.passURL.send(result.thumbnail)
            cell.playTime.text = "\(time / 60)m \(time % 60)s"
            cell.title.text = result.title.decodeHTML
            cell.datetime.text = result.datetime.dateString
        }
        return UITableViewCell()
    }
}

