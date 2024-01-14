//
//  NoResultViewController.swift
//  SearchApp
//
//  Created by LeeJaehoon on 2024/01/13.
//

import UIKit

class NoResultViewController: UIViewController {

    private let NopeImage: UIImageView = {
        let img = UIImageView()
        img.image = UIImage(systemName: "xmark")
        img.translatesAutoresizingMaskIntoConstraints = false
        return img
    }()

    private let script: UILabel = {
        let label = UILabel()
        label.text = "검색 결과가 없습니다"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }


    private func configureUI() {

        view.addSubview(NopeImage)
        view.addSubview(script)

        NSLayoutConstraint.activate([
            NopeImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            NopeImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            NopeImage.heightAnchor.constraint(equalToConstant: 250),
            NopeImage.widthAnchor.constraint(equalToConstant: 250),

            script.topAnchor.constraint(equalTo: NopeImage.bottomAnchor, constant: 20),
            script.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

}
