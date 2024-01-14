//
//  SearchHomeViewController.swift
//  SearchApp
//
//  Created by LeeJaehoon on 2024/01/13.
//

import UIKit

class SearchHomeViewController: UIViewController {

    private let glassImage: UIImageView = {
        let img = UIImageView()
        img.image = UIImage(systemName: "magnifyingglass")
        img.translatesAutoresizingMaskIntoConstraints = false
        return img
    }()

    private let script: UILabel = {
        let label = UILabel()
        label.text = "검색어를 입력하세요"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }


    private func configureUI() {

        view.addSubview(glassImage)
        view.addSubview(script)

        NSLayoutConstraint.activate([
            glassImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            glassImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            glassImage.heightAnchor.constraint(equalToConstant: 250),
            glassImage.widthAnchor.constraint(equalToConstant: 250),

            script.topAnchor.constraint(equalTo: glassImage.bottomAnchor, constant: 20),
            script.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

}
