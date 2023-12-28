//
//  URLEndPoint.swift
//  SearchApp
//
//  Created by LeeJaehoon on 2023/12/04.
//

import Foundation

enum EndPoint {
    case web(query: String, page: Int)
    case video(query: String, page: Int)
    case image(query: String, page: Int)

    var url: URL? {
        let baseURL = "https://dapi.kakao.com/v2/search"

        switch self {
        case .web(let query, let page):
            let str = "\(baseURL)/web?query=\(query)&page=\(page)"
            return URL(string: str.encodeURL()!)
        case .video(let query, let page):
            let str = "\(baseURL)/vclip?query=\(query)&page=\(page)"
            return URL(string: str.encodeURL()!)
        case .image(let query, let page):
            let str = "\(baseURL)/image?query=\(query)&page=\(page)"
            return URL(string: str.encodeURL()!)
        }
    }
}
