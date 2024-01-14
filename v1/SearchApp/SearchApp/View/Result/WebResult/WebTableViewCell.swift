//
//  WebTableViewCell.swift
//  SearchApp
//
//  Created by LeeJaehoon on 2024/01/14.
//

import UIKit

class WebTableViewCell: UITableViewCell {

    static let identifier = "webTableViewCell"

    let title: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let contents: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .light)
        label.lineBreakMode = .byCharWrapping
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let date: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(title)
        containerView.addSubview(contents)
        containerView.addSubview(date)

        NSLayoutConstraint.activate([

            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            title.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            title.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            title.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 5),

            contents.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            contents.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            contents.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 5),

            date.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            date.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            date.topAnchor.constraint(equalTo: contents.bottomAnchor, constant: 5),
            date.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -5)

        ])
    }

    
}
