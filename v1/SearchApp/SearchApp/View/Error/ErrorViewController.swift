//
//  ErrorViewController.swift
//  SearchApp
//
//  Created by LeeJaehoon on 2024/01/03.
//

import UIKit

class ErrorViewController: UIViewController {

    // MARK: - Properties
    var coordinator: MainCoordinator?
    var error: Error?

    private let errorImage: UIImageView = {
        let image = UIImageView()
        var config = UIImage.SymbolConfiguration(paletteColors: [.systemRed])
        image.image = UIImage(systemName: "exclamationmark.circle.fill", withConfiguration: config)
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()

    private let errorDescription: UILabel = {
        let label = UILabel()
        label.text = "error description"
        label.font = UIFont.systemFont(ofSize: 25)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        configureError()
        configureUI()
    }  

    // MARK: - Actions

    // MARK: - Helpers
    private func configureError() {
        switch error {
        case (let apiError as APIError):
            self.errorDescription.text = apiError.localizedDescription
            print(apiError.description)
        default:
            self.errorDescription.text = error?.localizedDescription
            return // 추가 custom Error가 있는 경우 정의합니다.
        }
    }

    private func configureUI() {

        view.backgroundColor = .white

        let safeArea = view.safeAreaLayoutGuide

        view.addSubview(errorImage)
        view.addSubview(errorDescription)

        NSLayoutConstraint.activate([
            errorImage.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            errorImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorImage.heightAnchor.constraint(equalToConstant: 250),
            errorImage.widthAnchor.constraint(equalToConstant: 250),

            errorDescription.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            errorDescription.topAnchor.constraint(equalTo: errorImage.bottomAnchor, constant: 50)

        ])
    }
}
