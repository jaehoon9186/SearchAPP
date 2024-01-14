//
//  RecordTableViewCell.swift
//  SearchApp
//
//  Created by LeeJaehoon on 2024/01/13.
//

import UIKit

class RecordTableViewCell: UITableViewCell {

    static let identifier = "recordCell"

    private let logo: UIImageView = {
        var config = UIImage.SymbolConfiguration(paletteColors: [.black])
        let image = UIImageView()
        image.image = UIImage(systemName: "clock.arrow.circlepath", withConfiguration: config)
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()

    let word: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var deleteButton: UIButton = {
        var config = UIImage.SymbolConfiguration(paletteColors: [.gray])
        let button = UIButton()
        button.addTarget(self, action: #selector(tapDeleteButton), for: .touchUpInside)
        button.setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: config), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    var onTapDeleteButton: (()->Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        configureUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc
    private func tapDeleteButton() {
        self.onTapDeleteButton?()
    }

    private func configureUI() {
        contentView.addSubview(logo)
        contentView.addSubview(word)
        contentView.addSubview(deleteButton)

        NSLayoutConstraint.activate([
            logo.widthAnchor.constraint(equalToConstant: 20),
            logo.heightAnchor.constraint(equalToConstant: 20),
            logo.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            logo.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),

            word.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            word.leadingAnchor.constraint(equalTo: logo.trailingAnchor, constant: 20),

            deleteButton.widthAnchor.constraint(equalToConstant: 20),
            deleteButton.heightAnchor.constraint(equalToConstant: 20),
            deleteButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            deleteButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20)

        ])
        
    }

}
