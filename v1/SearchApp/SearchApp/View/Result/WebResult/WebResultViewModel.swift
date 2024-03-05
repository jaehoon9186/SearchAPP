//
//  WebResultViewModel.swift
//  SearchApp
//
//  Created by LeeJaehoon on 2024/01/04.
//

import Foundation
import Combine

class WebResultViewModel: ViewModelType {

    struct Input {
        var searchWeb: AnyPublisher<String, Never>
    }

    struct Output {
        var fetchFail: AnyPublisher<Error, Never>
        var moreButtonisEnd: AnyPublisher<Void, Never>
        var fetchWebResult: AnyPublisher<[WebResult], Never>
    }

    private let apiService: APIServiceProtocol
    private var cancellable = Set<AnyCancellable>()

    // with api
    private var page: Int = 1

    // output
    private let errorSubject: PassthroughSubject<Error, Never> = .init()
    private let moreButtonisEndSubject: PassthroughSubject<Void, Never> = .init()
    private let webResultSubject: PassthroughSubject<[WebResult], Never> = .init()

    init(apiService: APIServiceProtocol = APIService()) {
        self.apiService = apiService
    }

    func transform(input: Input) -> Output {

        input.searchWeb
            .sink { [weak self] inputWord in
                self?.handleGetWebSearchResult(query: inputWord)
            }
            .store(in: &cancellable)

        return Output(fetchFail: errorSubject.eraseToAnyPublisher(),
                      moreButtonisEnd: moreButtonisEndSubject.eraseToAnyPublisher(),
                      fetchWebResult: webResultSubject.eraseToAnyPublisher())
    }

    private func handleGetWebSearchResult(query: String) {
        if query.isEmpty {
            self.webResultSubject.send([])
            return
        }

        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String else { return }

        guard let url = EndPoint.web(query: query, page: self.page).url else {
            self.errorSubject.send(APIError.invalidURL)
            return
        }

        var request = URLRequest (url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = ["Authorization": "KakaoAK \(apiKey)"]

        apiService.getFetchSearch(type: WebSearch.self, request: request)
            .sink { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.errorSubject.send(error)
                case .finished: break
                }
            } receiveValue: { [weak self] result in

                if let meta = result.meta, meta.isEnd {
                    self?.moreButtonisEndSubject.send()
                } else {
                    self?.page += 1
                }

                if let webResultList = result.webResults {
                    self?.webResultSubject.send(webResultList)
                }

            }.store(in: &cancellable)
    }
    
}
