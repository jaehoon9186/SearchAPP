//
//  CollectionViewCell.swift
//  SearchApp
//
//  Created by LeeJaehoon on 2024/01/05.
//

import Foundation
import UIKit
import Combine

class CollectionViewCell: UICollectionViewCell {

    static let identifier = "CustomCollectionViewCell"

    private let input: PassthroughSubject<CollectionCellViewModel.Input, Never> = .init()
    let pass: PassthroughSubject<ImageResult, Never> = .init()
    private var cancellable = Set<AnyCancellable>()

    private let viewModel = CollectionCellViewModel()

    private var image: UIImageView = {
        let image = UIImageView()
        image.backgroundColor = .lightGray
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        bind()
        configureUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        image.image = nil
    }

    func bind() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
            switch output {
            case .fetchUIImage(image: let image):
                self?.image.image = image
            }
        }.store(in: &cancellable)

        pass.sink { [weak self] result in
            self?.input.send(.requestImage(urlStr: result.imageURL))
        }.store(in: &cancellable)
    }

    private func configureUI() {
        contentView.addSubview(image)

        NSLayoutConstraint.activate([
            image.topAnchor.constraint(equalTo: contentView.topAnchor),
            image.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            image.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            image.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        ])

    }

}

