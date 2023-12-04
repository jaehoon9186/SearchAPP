//
//  ImageSearch.swift
//  SearchApp
//
//  Created by LeeJaehoon on 2023/12/04.
//

import Foundation

// MARK: - ImageSearch
struct ImageSearch: Codable {
    let meta: Meta
    let imageResults: [ImageResult]

    enum CodingKeys: String, CodingKey {
        case meta
        case imageResults = "documents"
    }
}

// MARK: - ImageResult
struct ImageResult: Codable {
    let collection: String
    let thumbnailURL: String
    let imageURL: String
    let width, height: Int
    let displaySitename: String
    let docURL: String
    let datetime: Date

    enum CodingKeys: String, CodingKey {
        case collection
        case thumbnailURL = "thumbnail_url"
        case imageURL = "image_url"
        case width, height
        case displaySitename = "display_sitename"
        case docURL = "doc_url"
        case datetime
    }
}
