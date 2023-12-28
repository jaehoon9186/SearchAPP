//
//  APIService.swift
//  SearchApp
//
//  Created by LeeJaehoon on 2023/12/04.
//

import Foundation
import Combine

class APIService {

    func getFetchResult<T: Decodable>(type: T.Type, request: URLRequest?) -> AnyPublisher<T, Error> {

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.sssZ"
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(formatter)

        return URLSession.shared.dataTaskPublisher(for: request!)
            .catch { error in
                return Fail(error: APIError.transportError(error)).eraseToAnyPublisher()
            }
            .map { $0.data }
            .decode(type: type, decoder: decoder)
            .eraseToAnyPublisher()
    }


    // composition 이용 재사용성 증가, 모듈화.
    func fetchSearchResult<T: Decodable>(_ type: T.Type, request: URLRequest?, completion: @escaping (Result<T, APIError>) -> Void) {

        guard let request = request else {
            let error = APIError.invalidRequest
            completion(Result.failure(error))
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in

            if let error = error {
                completion(Result.failure(APIError.transportError(error)))
            }

            if let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) == false {
                completion(Result.failure(APIError.badResponse(stateCode: response.statusCode)))
            }

            if let data = data {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.sssZ"
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(formatter)

                do {
                    let result = try decoder.decode(type, from: data)
                    completion(Result.success(result))
                } catch {
                    completion(Result.failure(APIError.parsingError))
                }

            }

        }

        task.resume()

    }

    func fetchSuggestion(url: URL?, completion: @escaping (Result<Suggestion, APIError>) -> Void) {
        guard let url = url else {
            completion(Result.failure(APIError.invalidURL))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(Result.failure(APIError.transportError(error)))
            }

            if let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) == false {
                completion(Result.failure(APIError.badResponse(stateCode: response.statusCode)))
            }

            if let data = data {
                let decoder = SuggestionXMLParser()

                do {
                    let result = try decoder.xmlDecode(data: data)
                    completion(Result.success(result))
                } catch {
                    completion(Result.failure(APIError.parsingError))
                }

            }
        }

        task.resume()
    }

    func fetchSearchWebResult(request: URLRequest?, completion: @escaping (Result<WebSearch, APIError>) -> Void) {
        guard let request = request else {
            let error = APIError.invalidRequest
            completion(Result.failure(error))
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in

            if let error = error {
                completion(Result.failure(APIError.transportError(error)))
            }

            if let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) == false {
                completion(Result.failure(APIError.badResponse(stateCode: response.statusCode)))
            }

            if let data = data {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.sssZ"
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(formatter)

                do {
                    let result = try decoder.decode(WebSearch.self, from: data)
                    completion(Result.success(result))
                } catch {
                    completion(Result.failure(APIError.parsingError))
                }

            }

        }

        task.resume()

    }

    func fetchSearchVideoResult(request: URLRequest?, completion: @escaping (Result<VideoSearch, APIError>) -> Void) {
        guard let request = request else {
            let error = APIError.invalidRequest
            completion(Result.failure(error))
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in

            if let error = error {
                completion(Result.failure(APIError.transportError(error)))
            }

            if let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) == false {
                completion(Result.failure(APIError.badResponse(stateCode: response.statusCode)))
            }

            if let data = data {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.sssZ"
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(formatter)

                do {
                    let result = try decoder.decode(VideoSearch.self, from: data)
                    completion(Result.success(result))
                } catch {
                    completion(Result.failure(APIError.parsingError))
                }

            }

        }

        task.resume()

    }

    func fetchSearchImageResult(request: URLRequest?, completion: @escaping (Result<ImageSearch, APIError>) -> Void) {
        guard let request = request else {
            let error = APIError.invalidRequest
            completion(Result.failure(error))
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in

            if let error = error {
                completion(Result.failure(APIError.transportError(error)))
            }

            if let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) == false {
                completion(Result.failure(APIError.badResponse(stateCode: response.statusCode)))
            }

            if let data = data {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.sssZ"
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(formatter)

                do {
                    let result = try decoder.decode(ImageSearch.self, from: data)
                    completion(Result.success(result))
                } catch {
                    completion(Result.failure(APIError.parsingError))
                }

            }

        }

        task.resume()
    }
}
