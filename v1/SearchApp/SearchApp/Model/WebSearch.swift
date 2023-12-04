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

    enum CodingKeys: String, CodingKey {
        case meta
        case webResults = "documents"
    }
}

// MARK: - WebResult
struct WebResult: Codable {
    let datetime: Date
    let contents, title: String
    let url: String
}
