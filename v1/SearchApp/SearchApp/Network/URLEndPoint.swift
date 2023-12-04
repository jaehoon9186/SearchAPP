//
//  URLEndPoint.swift
//  SearchApp
//
//  Created by LeeJaehoon on 2023/12/04.
//

import Foundation

enum EndPoint {
    case web(query: String)
    case video(query: String)
    case image(query: String)

    var url: URL? {
        let baseURL = "https://dapi.kakao.com/v2/search"

        switch self {
        case .web(let query):
            let str = "\(baseURL)/web?query=\(query)"
            return URL(string: str.encodeURL()!)
        case .video(let query):
            let str = "\(baseURL)/vclip?query=\(query)"
            return URL(string: str.encodeURL()!)
        case .image(let query):
            let str = "\(baseURL)/image?query=\(query)"
            return URL(string: str.encodeURL()!)
        }
    }
}
