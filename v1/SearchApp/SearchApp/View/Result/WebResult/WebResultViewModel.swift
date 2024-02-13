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
        var updateUI: AnyPublisher<Void, Never>
        var moreButtonisEnd: AnyPublisher<Void, Never>
    }

    private let apiService: APIService
    private var cancellable = Set<AnyCancellable>()

    // dataSource
    private var page: Int = 1
    var webResultList: [WebResult] = []

    // output
    private let errorSubject: PassthroughSubject<Error, Never> = .init()
    private let updateUISubject: PassthroughSubject<Void, Never> = .init()
    private let moreButtonisEndSubject: PassthroughSubject<Void, Never> = .init()

    init(apiService: APIService = APIService()) {
        self.apiService = apiService
    }

    func transform(input: Input) -> Output {

        input.searchWeb
            .sink { [weak self] inputWord in
                self?.handleWebSearchResult(query: inputWord) {
                    self?.updateUISubject.send()
                }
            }
            .store(in: &cancellable)

        return Output(fetchFail: errorSubject.eraseToAnyPublisher(),
                      updateUI: updateUISubject.eraseToAnyPublisher(),
                      moreButtonisEnd: moreButtonisEndSubject.eraseToAnyPublisher())
    }

    private func handleWebSearchResult(query: String, completion: @escaping () -> Void) {
        if query.isEmpty {
            self.webResultList = []
            completion()
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

        apiService.getFetchResult(type: WebSearch.self, request: request)
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

                self?.webResultList += result.webResults!
                completion()
            }.store(in: &cancellable)
    }
    
}
