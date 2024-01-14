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
    

    func start() {
        let vc = SearchViewController()
        vc.coordinator = self
        self.navigationController?.viewControllers = [vc]
    }
}
