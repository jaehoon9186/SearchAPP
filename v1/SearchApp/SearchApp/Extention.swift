//
//  Extention.swift
//  SearchApp
//
//  Created by LeeJaehoon on 2023/12/04.
//

import Foundation

extension String {
    func encodeURL() -> String? {
        return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }
}
