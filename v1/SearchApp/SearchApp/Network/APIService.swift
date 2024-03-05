//
//  APIService.swift
//  SearchApp
//
//  Created by LeeJaehoon on 2023/12/04.
//

import Foundation
import Combine
import UIKit

protocol APIServiceProtocol {
    func getFetchImage(url: URL) -> AnyPublisher<UIImage?, APIError>
    func getFetchSearch<T: Decodable>(type: T.Type, request: URLRequest?) -> AnyPublisher<T, APIError>
    func getFetchSuggestion(url: URL?) -> AnyPublisher<Suggestion, APIError>
}

protocol URLSessionProtocol {
    typealias APIResponse = URLSession.DataTaskPublisher.Output
    func response(for request: URLRequest) -> AnyPublisher<APIResponse, URLError>
    func response(for url: URL) -> AnyPublisher<APIResponse, URLError>
}

extension URLSession: URLSessionProtocol {
    func response(for request: URLRequest) -> AnyPublisher<APIResponse, URLError> {
        return dataTaskPublisher(for: request).eraseToAnyPublisher()
    }
    func response(for url: URL) -> AnyPublisher<APIResponse, URLError> {
        return dataTaskPublisher(for: url).eraseToAnyPublisher()
    }
}


class APIService: APIServiceProtocol {

    private let session: URLSessionProtocol

    init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }



    func getFetchImage(url: URL) -> AnyPublisher<UIImage?, APIError> {
        return session.response(for: url)
            .catch { error in
                Fail(error: APIError.transportError(error))
            }
            .map { UIImage(data: $0.data) }
            .eraseToAnyPublisher()
    }

    func getFetchSearch<T: Decodable>(type: T.Type, request: URLRequest?) -> AnyPublisher<T, APIError> {

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.sssZ"
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(formatter)

        guard let request = request else {
            return Fail(error: APIError.invalidRequest).eraseToAnyPublisher()
        }

        return session.response(for: request)
            .catch { error in
                Fail(error: APIError.transportError(error))
            }
            .tryMap { (data, response) in
                if let response = response as? HTTPURLResponse,
                   !(200...299).contains(response.statusCode) {
                    throw APIError.badResponse(stateCode: response.statusCode)
                } else {
                    return data
                }
            }
            .decode(type: type, decoder: decoder)
            .catch { _ in
                Fail(error: APIError.parsingError)
            }
            .eraseToAnyPublisher()
    }


    // composition 이용 재사용성 증가, 모듈화.
//    func fetchSearchResult<T: Decodable>(_ type: T.Type, request: URLRequest?, completion: @escaping (Result<T, APIError>) -> Void) {
//
//        guard let request = request else {
//            let error = APIError.invalidRequest
//            completion(Result.failure(error))
//            return
//        }
//
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//
//            if let error = error {
//                completion(Result.failure(APIError.transportError(error)))
//            }
//
//            if let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) == false {
//                completion(Result.failure(APIError.badResponse(stateCode: response.statusCode)))
//            }
//
//            if let data = data {
//                let formatter = DateFormatter()
//                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.sssZ"
//                let decoder = JSONDecoder()
//                decoder.dateDecodingStrategy = .formatted(formatter)
//
//                do {
//                    let result = try decoder.decode(type, from: data)
//                    completion(Result.success(result))
//                } catch {
//                    completion(Result.failure(APIError.parsingError))
//                }
//
//            }
//
//        }
//
//        task.resume()
//
//    }


    func getFetchSuggestion(url: URL?) -> AnyPublisher<Suggestion, APIError> {

        let decoder = SuggestionXMLParser()

        guard let url = url else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }

        return session.response(for: url)
            .catch { error in
                Fail(error: APIError.transportError(error)).eraseToAnyPublisher()
            }
            .tryMap({ output in
                if let response = output.response as? HTTPURLResponse,
                   !(200...299).contains(response.statusCode) {
                    throw APIError.badResponse(stateCode: response.statusCode)
                } else {
                    return try decoder.xmlDecode(data: output.data)
                }
            })
            .catch { _ in
                Fail(error: APIError.parsingError).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()

    }

//    func fetchSuggestion(url: URL?, completion: @escaping (Result<Suggestion, APIError>) -> Void) {
//        guard let url = url else {
//            completion(Result.failure(APIError.invalidURL))
//            return
//        }
//
//        let task = URLSession.shared.dataTask(with: url) { data, response, error in
//            if let error = error {
//                completion(Result.failure(APIError.transportError(error)))
//            }
//
//            if let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) == false {
//                completion(Result.failure(APIError.badResponse(stateCode: response.statusCode)))
//            }
//
//            if let data = data {
//                let decoder = SuggestionXMLParser()
//
//                do {
//                    let result = try decoder.xmlDecode(data: data)
//                    completion(Result.success(result))
//                } catch {
//                    completion(Result.failure(APIError.parsingError))
//                }
//
//            }
//        }
//
//        task.resume()
//    }

}
