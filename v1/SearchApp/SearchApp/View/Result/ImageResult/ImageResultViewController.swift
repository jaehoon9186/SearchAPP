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

    var viewModel: ImageResultViewModel!

    // input
    let searchImageSubject: CurrentValueSubject<String, Never> = .init("")

    private var cancellable = Set<AnyCancellable>()

    private var button: MoreButtonView?

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

//        bind()
        configureUI()
        configureDelegate()
    }

    override func viewDidAppear(_ animated: Bool) {
        bind()
    }

    // MARK: - Actions


    // MARK: - Helpers
    private func configureDelegate() {
        collectionView.dataSource = self
        collectionView.delegate = self
    }


    private func bind() {
        let input = ImageResultViewModel.Input(searchImage: searchImageSubject.eraseToAnyPublisher())

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
                self?.collectionView.reloadData()
            }
            .store(in: &cancellable)
    }

//    private func collectionViewUpdate(items: ImageSearch) {
//        var index = self.list.count
//
//        if let results = items.imageResults {
//            results.forEach({
//                self.list.insert($0, at: index)
//                self.collectionView.insertItems(at: [IndexPath(item: index, section: 0)])
//                index += 1
//            })
//        }
//    }

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
        viewModel.ImageResultList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCollectionViewCell", for: indexPath) as?  CollectionViewCell {

            cell.pass.send(viewModel.ImageResultList[indexPath.row])

            return cell
        }
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate?.goDetailView(url: viewModel.ImageResultList[indexPath.row].docURL)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        switch kind {
        case UICollectionView.elementKindSectionFooter:
            let footer = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "CustomCollectionFooterView",
                for: indexPath
            ) as! CollectionFooterView

            self.button = MoreButtonView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 100))

            footer.buttonView = self.button

            footer.buttonView?.onButtonTap = { [weak self] in
                self?.searchImageSubject.send(self?.searchImageSubject.value ?? "")
            }
            
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
