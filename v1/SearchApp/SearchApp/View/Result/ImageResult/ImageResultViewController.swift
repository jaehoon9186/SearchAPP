//
//  ImageResultViewController.swift
//  SearchApp
//
//  Created by LeeJaehoon on 2023/12/15.
//

import UIKit
import Combine

protocol ImageResultViewControllerDelegate {
    func goErrorView(error: Error)
    func goDetailView(url: String)
}

class ImageResultViewController: UIViewController {
    // MARK: - Properties
    var delegate: ImageResultViewControllerDelegate?

    private let viewModel = ImageResultViewModel()
    private let input: PassthroughSubject<ImageResultViewModel.Input, Never> = .init()

    private let resultSubject: PassthroughSubject<ImageSearch, Never> = .init()
    private var cancellable = Set<AnyCancellable>()

    private var isEnd: CurrentValueSubject<Bool, Never> = .init(false)

    private var list: [ImageResult] = []
    private var nextPage: Int?
    private var searchWord: String?


    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        layout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        layout.itemSize = CGSize(width: (view.frame.width / 2) - 2, height: (view.frame.width / 2) - 2)

        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(CollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewCell.identifier)

        collection.register(CollectionFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: CollectionFooterView.identifier)

        collection.contentInsetAdjustmentBehavior = .always
        collection.keyboardDismissMode = .onDrag
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .purple

        bind()
        configureUI()
        configureDelegate()
    }

    // MARK: - Actions


    // MARK: - Helpers
    private func configureDelegate() {
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    func sendSearchWord(word: String) {
        searchWord = word
        input.send(.ImageButtonTap(query: searchWord ?? ""))
    }

    private func updateResult(result: ImageSearch, nowPage: Int) {
        if nowPage == 1 {
            list = []
            collectionView.reloadData()
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
                case .fetchImageSucceed(result: let result, nowPage: let nowPage):
                    self?.updateResult(result: result, nowPage: nowPage)
                }
            }
            .store(in: &cancellable)
        
        resultSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] imageSearch in
                self?.isEnd.send(imageSearch.meta!.isEnd)
                self?.collectionViewUpdate(items: imageSearch)
            }
            .store(in: &cancellable)
    }

    private func collectionViewUpdate(items: ImageSearch) {
        var index = self.list.count

        if let results = items.imageResults {
            results.forEach({
                self.list.insert($0, at: index)
                self.collectionView.insertItems(at: [IndexPath(item: index, section: 0)])
                index += 1
            })
        }
    }

    private func configureUI() {
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension ImageResultViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return list.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCollectionViewCell", for: indexPath) as?  CollectionViewCell {
            cell.pass.send(list[indexPath.row])

            return cell
        }
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate?.goDetailView(url: list[indexPath.row].docURL)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        switch kind {
        case UICollectionView.elementKindSectionFooter:
            let footer = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "CustomCollectionFooterView",
                for: indexPath
            ) as! CollectionFooterView

            footer.buttonView = MoreButtonView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 100))

            footer.buttonView?.onButtonTap = { [weak self] in
                self?.input.send(.ImageButtonTap(query: self?.searchWord ?? "", page: self?.nextPage ?? 1))
            }

            isEnd
                .receive(on: DispatchQueue.main)
                .sink { isEnd in
                    footer.buttonView?.button.isEnabled = !isEnd
                }
                .store(in: &cancellable)

            return footer
        default:
            print("default")
        }

        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.size.width, height: 200)
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

}
