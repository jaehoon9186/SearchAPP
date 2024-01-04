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
    private var temporarySearchWord: PassthroughSubject<String, Never> = .init()

    private lazy var searchBar: UISearchBar = {
        let search = UISearchBar()
        search.placeholder = "검색어를 입력해 주세요."
        search.showsScopeBar = true
        search.scopeButtonTitles = ["web", "image", "video"]
        search.translatesAutoresizingMaskIntoConstraints = false
        return search
    }()
    // 검색 관련
    // 1. 서치바 키보드 완료(return)버튼 액션
    // 2. 키보드 레이아웃 밖? 아웃사이드 버튼 액션
    // 3. scope bar button 액션, 그냥 버튼으로 만들어볼 것. (기존의 버튼 탭이 불가해서)

    private let suggestionVC: SuggestionViewController = {
        let vc = SuggestionViewController()
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        return vc
    }()

    private let webResultVC: WebResultViewController = {
        let vc = WebResultViewController()
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        return vc
    }()

    private let imageResultVC: ImageResultViewController = {
        let vc = ImageResultViewController()
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        return vc
    }()

    private let videoResultVC: VideoResultViewController = {
        let vc = VideoResultViewController()
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        return vc
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        bind()
        configureDelegate()
        configureUI()
        configureChildVC()
    }
    // MARK: - Actions

    // MARK: - Helpers
    private func bind() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case .fetchFail(let error):
                    self?.coordinator?.pushErrorView(error: error)
                case .fetchWebSucceed(let result, let nowPage):
                    self?.webResultVC.updateResult(result: result, nowPage: nowPage)
                case .fetchImageSucceed(let result, let nowPage):
                    self?.imageResultVC.updateResult(result: result, nowPage: nowPage)
                case .fetchVideoSucceed(let result, let nowPage):
                    self?.videoResultVC.updateResult(result: result, nowPage: nowPage)
                case .fetchSuggestionSucceed(let result):
                    self?.suggestionVC.updateResult(result: result)
                case .fetchRelatedRecordSucceed(let result):
                    self?.suggestionVC.updateResult(result: result)
                }
            }.store(in: &cancellables)

        // 검색하거나 탭(scopeBar) 이동시 == 처음 검색하는 경우.
        searchWord.combineLatest(searchScopeNum)
            .sink { [weak self] (word, scope) in
                if word.isEmpty {
                    return
                }

                switch scope {
                case 0:
                    self?.input.send(.webButtonTap(query: word))
                case 1:
                    self?.input.send(.imageButtonTap(query: word))
                default:
                    self?.input.send(.videoButtonTap(query: word))
                }
            }
            .store(in: &cancellables)

        temporarySearchWord
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .sink { [weak self] word in
                self?.input.send(.searchingGetRecord(query: word))
                self?.input.send(.searchingGetSuggestion(query: word))
            }
            .store(in: &cancellables)
    }

    private func configureDelegate() {
        searchBar.delegate = self
        webResultVC.delegate = self
        imageResultVC.delegate = self
        videoResultVC.delegate = self

    }

    private func configureChildVC() {
        let safeArea = view.safeAreaLayoutGuide

        addChild(suggestionVC)
        addChild(webResultVC)
        addChild(imageResultVC)
        addChild(videoResultVC)

        view.addSubview(suggestionVC.view)
        view.addSubview(webResultVC.view)
        view.addSubview(imageResultVC.view)
        view.addSubview(videoResultVC.view)

        suggestionVC.didMove(toParent: self)
        webResultVC.didMove(toParent: self)
        imageResultVC.didMove(toParent: self)
        videoResultVC.didMove(toParent: self)

        NSLayoutConstraint.activate([
            suggestionVC.view.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            suggestionVC.view.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            suggestionVC.view.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            suggestionVC.view.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),

            webResultVC.view.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            webResultVC.view.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            webResultVC.view.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            webResultVC.view.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),

            imageResultVC.view.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            imageResultVC.view.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            imageResultVC.view.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            imageResultVC.view.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),

            videoResultVC.view.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            videoResultVC.view.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            videoResultVC.view.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            videoResultVC.view.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
    }

    private func configureUI() {
        self.navigationItem.title = "SEARCH"
        view.backgroundColor = .cyan

        let safeArea = view.safeAreaLayoutGuide

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

// 각 child VC 에서 버튼으로 추가정보를 원하는 경우.
extension SearchViewController: WebResultViewControllerDelegate {
    func moreWebResult(nextPage: Int) {
        input.send(.webButtonTap(query: self.searchWord.value, page: nextPage))
    }
}

extension SearchViewController: ImageResultViewControllerDelegate {
    func moreImageResult(nextPage: Int) {
        input.send(.imageButtonTap(query: self.searchWord.value, page: nextPage))
    }
}

extension SearchViewController: VideoResultViewControllerDelegate {
    func moreVideoResult(nextPage: Int) {
        input.send(.videoButtonTap(query: self.searchWord.value, page: nextPage))
    }
}

extension SearchViewController: UISearchBarDelegate {

    // outside touch?
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismissKeyboard()
    }

    func dismissKeyboard() {
        searchBar.resignFirstResponder()
    }

    // 키보드 search 버튼 수행.
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        dismissKeyboard()
        searchWord.send(searchBar.text ?? "")
        searchBar.endEditing(true)
        webResultVC.view.isHidden = false
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        suggestionVC.view.isHidden = false
        webResultVC.view.isHidden = true
        imageResultVC.view.isHidden = true
        videoResultVC.view.isHidden = true
        temporarySearchWord.send("")
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        temporarySearchWord.send(searchText)
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        dismissKeyboard()
    }

    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {

        dismissKeyboard()

        suggestionVC.view.isHidden = true
        webResultVC.view.isHidden = true
        imageResultVC.view.isHidden = true
        videoResultVC.view.isHidden = true

        if selectedScope == 0 {
            searchScopeNum.send(0)
            self.webResultVC.view.isHidden = false
        } else if selectedScope == 1 {
            searchScopeNum.send(1)
            self.imageResultVC.view.isHidden = false
        } else {
            searchScopeNum.send(2)
            self.videoResultVC.view.isHidden = false
        }
    }
}
