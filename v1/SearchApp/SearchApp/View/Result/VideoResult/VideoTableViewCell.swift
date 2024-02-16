//
//  VideoTableviewCell.swift
//  SearchApp
//
//  Created by LeeJaehoon on 2024/01/14.
//

import UIKit
import Combine

class VideoTableViewCell: UITableViewCell {

    static let identifier = "videoTableViewCell"

    private let input: PassthroughSubject<VideoTableViewCellViewModel.Input, Never> = .init()
    private var cancellable = Set<AnyCancellable>()
    let passURL: PassthroughSubject<String, Never> = .init()
    private let viewModel = VideoTableViewCellViewModel()

    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let thumbnail: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .systemGray
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    let title: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let playTime: PaddingLabel = {
        let label = PaddingLabel()
        label.backgroundColor = .white
        label.paddingRight = 10
        label.paddingLeft = 10
        label.paddingTop = 3
        label.paddingBottom = 3
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let datetime: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        bind()
        configureUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnail.image = nil
        title.text = nil
        playTime.text = nil
        datetime.text = nil
    }

    private func bind() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
            switch output {
            case .fetchUIImage(image: let image):
                self?.thumbnail.image = image
            }
        }.store(in: &cancellable)

        passURL
            .sink { [weak self] url in
            self?.input.send(.requestImage(urlStr: url))
        }.store(in: &cancellable)
    }

    private func configureUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(thumbnail)
        thumbnail.addSubview(playTime)
        containerView.addSubview(title)
        containerView.addSubview(datetime)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),

            thumbnail.topAnchor.constraint(equalTo: containerView.topAnchor),
            thumbnail.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            thumbnail.widthAnchor.constraint(equalTo: containerView.widthAnchor),
            thumbnail.heightAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.56),

            playTime.bottomAnchor.constraint(equalTo: thumbnail.bottomAnchor, constant: -3),
            playTime.trailingAnchor.constraint(equalTo: thumbnail.trailingAnchor, constant: -3),

            title.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            title.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            title.topAnchor.constraint(equalTo: thumbnail.bottomAnchor, constant: 5),

            datetime.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            datetime.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            datetime.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 5),
            datetime.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
}
