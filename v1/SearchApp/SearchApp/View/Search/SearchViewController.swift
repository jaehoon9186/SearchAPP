//
//  SearchViewController.swift
//  SearchApp
//
//  Created by LeeJaehoon on 2023/12/08.
//

import UIKit
import Combine


class SearchViewController: UIViewController {
    // MARK: - Properties
    weak var coordinator: MainCoordinator?

    var viewModel: SearchViewModel = SearchViewModel()
    private let input: PassthroughSubject<SearchViewModel.Input, Never> = .init()
    private var cancellables = Set<AnyCancellable>()

    private var searchWord: CurrentValueSubject<String, Never> = .init("")
    private var searchScopeNum: CurrentValueSubject<Int, Never> = .init(0)
    var temporarySearchWord: CurrentValueSubject<String, Never> = .init("")

    private lazy var searchBar: UISearchBar = {
        let search = UISearchBar()
        search.placeholder = "검색어를 입력해 주세요."
        search.showsScopeBar = true
        search.scopeButtonTitles = ["web", "image", "video"]
        search.translatesAutoresizingMaskIntoConstraints = false
        return search
    }()

    private lazy var safeArea = self.view.safeAreaLayoutGuide

    var currentSubViewController: UIViewController? {
        didSet {
            removePreviousSubViewController()
            if let newSubViewController = currentSubViewController {
                addChild(newSubViewController)
                view.addSubview(newSubViewController.view)
                newSubViewController.didMove(toParent: self)

                newSubViewController.view.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    newSubViewController.view.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
                    newSubViewController.view.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
                    newSubViewController.view.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
                    newSubViewController.view.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
                ])
            }
        }
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        bind()
        configureDelegate()
        configureUI()
    }
    // MARK: - Actions

    // MARK: - Helpers
    private func removePreviousSubViewController() {
        currentSubViewController?.willMove(toParent: nil)
        currentSubViewController?.view.removeFromSuperview()
        currentSubViewController?.removeFromParent()
    }

    private func bind() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case .fetchFail(let error):
                    self?.coordinator?.pushErrorView(error: error)
                }
            }.store(in: &cancellables)

        // 검색하거나 탭(scopeBar) 이동시 == 처음 검색하는 경우.
        searchWord.combineLatest(searchScopeNum)
            .sink { [weak self] (word, scope) in

                if word.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    return
                }

                self?.input.send(.searchTap(word: word))

                self?.coordinator?.showSubViewController(scopeIndex: scope, searchText: word, isEdting: false)
            }
            .store(in: &cancellables)

    }

    private func configureDelegate() {
        searchBar.delegate = self
    }

    private func configureUI() {
        self.navigationItem.title = "SEARCH"
        view.backgroundColor = .white

        view.addSubview(searchBar)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: safeArea.topAnchor),
            searchBar.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            searchBar.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: searchBar.frame.height)
        ])
    }
}
extension SearchViewController: SuggestionViewControllerDelegate {
    func updateSearchBar(word: String) {
        searchBar.text = word
        temporarySearchWord.send(word)
    }

    func goDetailView(error: Error) {
        coordinator?.pushErrorView(error: error)
    }
}

// 각 child VC 에서 버튼으로 추가정보를 원하는 경우.
extension SearchViewController: WebResultViewControllerDelegate, ImageResultViewControllerDelegate, VideoResultViewControllerDelegate {
    func goDetailView(url: String) {
        coordinator?.pushDetailView(url: url)
    }

    func goErrorView(error: Error) {
        coordinator?.pushErrorView(error: error)
    }
}


extension SearchViewController: UISearchBarDelegate {

    // outside touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismissKeyboard()
    }

    func dismissKeyboard() {
        searchBar.resignFirstResponder()
    }

    // 키보드 search 버튼 수행.
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchWord.send(searchBar.text ?? "")
        searchBar.endEditing(true)
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        coordinator?.showSubViewController(isEdting: true)
        temporarySearchWord.send(searchBar.text ?? "")
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        temporarySearchWord.send(searchText)
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        dismissKeyboard()
    }

    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {

        dismissKeyboard()

        if selectedScope == 0 {
            searchScopeNum.send(0)
        } else if selectedScope == 1 {
            searchScopeNum.send(1)
        } else {
            searchScopeNum.send(2)
        }
    }
}
