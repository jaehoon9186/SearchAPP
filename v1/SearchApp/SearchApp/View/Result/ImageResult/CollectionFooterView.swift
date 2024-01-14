//
//  CollectionFooterView.swift
//  SearchApp
//
//  Created by LeeJaehoon on 2024/01/11.
//

import UIKit

class CollectionFooterView: UICollectionReusableView {
    static let identifier = "CustomCollectionFooterView"

    var buttonView: MoreButtonView? {
        didSet {
            configureUI()
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureUI() {
        if let bv = buttonView {
            addSubview(bv)
        }
    }

}
