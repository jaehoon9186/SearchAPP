//
//  applicationCoordinator.swift
//  SearchApp
//
//  Created by LeeJaehoon on 2023/12/05.
//

import Foundation
import UIKit

class ApplicationCoordinator: Coordinator {

    let window: UIWindow?

    var childCoordinator = [Coordinator]()

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        let navigationController = UINavigationController()
        let mainCoordinator = MainCoordinator(navigationController: navigationController)
        window?.rootViewController = navigationController
        self.childCoordinator = [mainCoordinator]
        mainCoordinator.start()
        window?.makeKeyAndVisible()
    }
}
