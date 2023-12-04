//
//  WebSearch.swift
//  SearchApp
//
//  Created by LeeJaehoon on 2023/12/04.
//

import Foundation

// MARK: - WebSearch
struct WebSearch: Codable {
    let meta: Meta
    let webResults: [WebResult]
}

// MARK: - Document
struct WebResult: Codable {
    let datetime, contents, title: String
    let url: String
}
