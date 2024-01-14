//
//  ImageResultViewController.swift
//  SearchApp
//
//  Created by LeeJaehoon on 2023/12/15.
//

import UIKit
import Combine

protocol ImageResultViewControllerDelegate {
    func moreImageResult(nextPage: Int)
}

class ImageResultViewController: UIViewController {
    // MARK: - Properties
    var delegate: ImageResultViewControllerDelegate?

    private let resultSubject: PassthroughSubject<ImageSearch, Never> = .init()
    private var cancellable = Set<AnyCancellable>()

    private var isEnd: CurrentValueSubject<Bool, Never> = .init(false)

    private var list: [ImageResult] = []
    private var nextPage: Int?

    private var button: MoreButtonView?

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundView?.backgroundColor = .white
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        return tableView
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .purple

        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .onDrag

        bind()
        configureUI()
    }

    // MARK: - Actions


    // MARK: - Helpers

    // from parent View
    func updateResult(result: ImageSearch, nowPage: Int) {
        if nowPage == 1 {
            list = []
        }
        nextPage = nowPage + 1
        resultSubject.send(result)
    }

    private func bind() {

        resultSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] ImageSearch in
                self?.isEnd.send(ImageSearch.meta.isEnd)
                self?.list += ImageSearch.imageResults
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

        button?.onButtonTap = {
            self.delegate?.moreImageResult(nextPage: self.nextPage ?? 1)
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


extension ImageResultViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        list.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = list[indexPath.row].displaySitename
        return cell
    }
}
