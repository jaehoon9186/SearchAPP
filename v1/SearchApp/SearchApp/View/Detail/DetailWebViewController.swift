//
//  DetailWebViewController.swift
//  SearchApp
//
//  Created by LeeJaehoon on 2024/01/10.
//

import UIKit
import SafariServices

class DetailSafariViewController: UIViewController, SFSafariViewControllerDelegate{

    var url: String?

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let safariview = SFSafariViewController(url: URL(string: url!)!)
        safariview.delegate = self
        self.present(safariview, animated: false)

    }

    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }

    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        self.navigationController?.popViewController(animated: false)
    }


}
