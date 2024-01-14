//
//  SuggestionTableViewCell.swift
//  SearchApp
//
//  Created by LeeJaehoon on 2024/01/13.
//

import UIKit

class SuggestionTableViewCell: UITableViewCell {

    static let identifier = "suggestionCell"

    private let logo: UIImageView = {
        var config = UIImage.SymbolConfiguration(paletteColors: [.black])
        let image = UIImageView()
        image.image = UIImage(systemName: "magnifyingglass", withConfiguration: config)
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()

    let word: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        configureUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureUI() {
        contentView.addSubview(logo)
        contentView.addSubview(word)

        NSLayoutConstraint.activate([
            logo.widthAnchor.constraint(equalToConstant: 20),
            logo.heightAnchor.constraint(equalToConstant: 20),
            logo.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            logo.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),

            word.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            word.leadingAnchor.constraint(equalTo: logo.trailingAnchor, constant: 20)

        ])

    }

}
