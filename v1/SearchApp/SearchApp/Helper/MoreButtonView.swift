//
//  MoreButtonView.swift
//  SearchApp
//
//  Created by LeeJaehoon on 2023/12/19.
//

import UIKit

class MoreButton: UIButton {
    override var isEnabled: Bool {
        didSet {
            alpha = isEnabled ? 1.0 : 0.5
            setTitle(isEnabled ? "more" : "end", for: .normal)
        }
    }
}

class MoreButtonView: UIView {

    var onButtonTap: (()->Void)?

    lazy var button: MoreButton = {
        let button = MoreButton()
        button.setTitle("more", for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(tapButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        configureUI()

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc
    private func tapButton() {
        self.onButtonTap?()
    }

    private func configureUI() {
        self.addSubview(button)

        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            button.widthAnchor.constraint(equalToConstant: 100),
            button.heightAnchor.constraint(equalToConstant: 30)
        ])

    }

}
