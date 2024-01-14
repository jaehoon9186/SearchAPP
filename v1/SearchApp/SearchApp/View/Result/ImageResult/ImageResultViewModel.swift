//
//  ImageResultViewModel.swift
//  SearchApp
//
//  Created by LeeJaehoon on 2024/01/05.
//

import Foundation
import Combine

class ImageResultViewModel {
    enum Input {
        case ImageButtonTap(query: String, page: Int = 1)
    }

    enum Output {
        case fetchFail(error: Error)
        case fetchImageSucceed(result: ImageSearch, nowPage: Int)
    }

    private let apiService: APIService
    private let output: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()

    init(apiService: APIService = APIService()) {
        self.apiService = apiService
    }

    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input
            .sink { [weak self] event in
                switch event {
                case .ImageButtonTap(let query, let page):
                    self?.handleGetSearchResult(url: EndPoint.image(query: query, page: page).url, nowPage: page)
                }
            }
            .store(in: &cancellables)

        return output.eraseToAnyPublisher()
    }

    private func handleGetSearchResult(url: URL?, nowPage: Int) {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String else { return }

        var request = URLRequest (url: url!)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = ["Authorization": "KakaoAK \(apiKey)"]

        apiService.getFetchResult(type: ImageSearch.self, request: request)
            .sink { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.output.send(Output.fetchFail(error: error))
                case .finished: break
                }
            } receiveValue: { [weak self] result in
                self?.output.send(Output.fetchImageSucceed(result: result, nowPage: nowPage))
            }.store(in: &cancellables)
    }

}
