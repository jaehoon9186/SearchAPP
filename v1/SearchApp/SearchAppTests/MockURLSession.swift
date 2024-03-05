//
//  MockURLSession.swift
//  SearchAppTests
//
//  Created by LeeJaehoon on 2024/03/04.
//

import Foundation
import Combine
import UIKit
@testable import SearchApp

class MockURLSession: URLSessionProtocol, JSONLoadable {

    enum RequestMethod {
        case fetchImage
        case fetchSearch
        case fetchSuggestion
    }

    let lastRequestMethod: RequestMethod
    let makeRequestFail: Bool

    init(lastRequestMethod: RequestMethod, makeRequestFail: Bool = false) {
        self.lastRequestMethod = lastRequestMethod
        self.makeRequestFail = makeRequestFail
    }

    func response(for request: URLRequest) -> AnyPublisher<APIResponse, URLError> {

        var data = Data()
        var response = HTTPURLResponse()

        if makeRequestFail {
            response = HTTPURLResponse(url: request.url!, statusCode: 400, httpVersion: "2", headerFields: nil)!
            return Just((data: Data(), response: response))
                .setFailureType(to: URLError.self)
                .eraseToAnyPublisher()
        }

        switch lastRequestMethod {
        case .fetchSearch:
            response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: "2", headerFields: nil)!
            data = loadJSON(filename: "WebSearchResponse")
            break
        default:
            response = HTTPURLResponse(url: request.url!, statusCode: 400, httpVersion: "2", headerFields: nil)!
            break
        }

        // (data: Data, response: URLResponse)의 named tuple
        return Just((data: data, response: response))
            .setFailureType(to: URLError.self)
            .eraseToAnyPublisher()
    }

    func response(for url: URL) -> AnyPublisher<APIResponse, URLError> {

        var data = Data()
        var response = HTTPURLResponse()

        if makeRequestFail {
            response = HTTPURLResponse(url: url, statusCode: 400, httpVersion: "2", headerFields: nil)!
            return Just((data: data, response: response))
                .setFailureType(to: URLError.self)
                .eraseToAnyPublisher()
        }

        switch lastRequestMethod {
        case .fetchImage:
            data = UIImage(systemName: "checkmark.seal")!.pngData()!
            response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "2", headerFields: nil)!
            break
        case .fetchSuggestion:
//            let suggestion = Suggestion(suggestedWords: ["cat", "dog", "bird", "ant"])
//            data = try! JSONEncoder().encode(suggestion)
            // XML data를 전달해야함.
//            response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "2", headerFields: nil)!
            break
        default:
            response = HTTPURLResponse(url: url, statusCode: 400, httpVersion: "2", headerFields: nil)!
            break
        }

        return Just((data: data, response: response))
            .setFailureType(to: URLError.self)
            .eraseToAnyPublisher()
    }

}
