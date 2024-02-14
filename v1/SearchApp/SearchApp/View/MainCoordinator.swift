//
//  MainCoordinator.swift
//  SearchApp
//
//  Created by LeeJaehoon on 2023/12/05.
//

import Foundation
import UIKit
import SafariServices

class MainCoordinator: Coordinator {
    var navigationController: UINavigationController?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    // toError
    func pushErrorView(error: Error) {
        let vc = ErrorViewController()
        vc.coordinator = self
        vc.error = error
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func pushDetailView(url: String) {
        let vc = DetailSafariViewController()
        vc.url = url
                navigationController?.pushViewController(vc, animated: true)
    }

    func showSubViewController(scopeIndex: Int? = nil, searchText: String? = nil, isEdting: Bool) {
        guard let searchVC = navigationController?.topViewController as? SearchViewController else {
            return
        }

        var nextSubViewController: UIViewController

        if isEdting == true {
            let suggestionVC = SuggestionViewController()
            let viewModel = SuggestionViewModel()
            suggestionVC.delegate = searchVC
            suggestionVC.viewModel = viewModel
            nextSubViewController = suggestionVC
        } else {
            guard let scopeIndex = scopeIndex, let searchText = searchText else {
                return
            }

            switch scopeIndex {
            case 0:
                let webResultVC = WebResultViewController()
                let viewModel = WebResultViewModel()
                webResultVC.delegate = searchVC
                webResultVC.viewModel = viewModel
                webResultVC.searchWebSubject.send(searchText)
                nextSubViewController = webResultVC
            case 1:
                let imageResultVC = ImageResultViewController()
                let viewModel = ImageResultViewModel()
                imageResultVC.delegate = searchVC
                imageResultVC.viewModel = viewModel
                imageResultVC.searchImageSubject.send(searchText)
                nextSubViewController = imageResultVC
            case 2:
                let videoResultVC = VideoResultViewController()
                let viewModel = VideoResultViewModel()
                videoResultVC.delegate = searchVC
                videoResultVC.viewModel = viewModel
                videoResultVC.searchVideoSubject.send(searchText)
                nextSubViewController = videoResultVC
            default:
                return
            }
        }

        searchVC.currentSubViewController = nextSubViewController
    }

    func start() {
        let vc = SearchViewController()
        vc.coordinator = self

        let searchHomeVC = SearchHomeViewController()
        vc.currentSubViewController = searchHomeVC
        
        self.navigationController?.viewControllers = [vc]
    }
}
