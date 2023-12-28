//
//  MainCoordinator.swift
//  SearchApp
//
//  Created by LeeJaehoon on 2023/12/05.
//

import Foundation
import UIKit

class MainCoordinator: Coordinator {
    var navigationController: UINavigationController?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    // toError

    // toDetailView
    

    func start() {
        
        let vc = SearchViewController()
        vc.coordinator = self
        self.navigationController?.viewControllers = [vc]
    }
}
