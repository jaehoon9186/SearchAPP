//
//  VideoSearch.swift
//  SearchApp
//
//  Created by LeeJaehoon on 2023/12/04.
//

import Foundation


// MARK: - VideoSearch
struct VideoSearch: Codable {
    let meta: Meta
    let videoResults: [VideoResult]
}

// MARK: - Document
struct VideoResult: Codable {
    let title: String
    let playTime: Int
    let thumbnail: String
    let url: String
    let datetime: Date
    let author: String

    enum CodingKeys: String, CodingKey {
        case title
        case playTime = "play_time"
        case thumbnail, url, datetime, author
    }
}
