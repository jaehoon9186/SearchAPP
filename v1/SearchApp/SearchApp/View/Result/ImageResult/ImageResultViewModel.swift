//
//  ImageResultViewModel.swift
//  SearchApp
//
//  Created by LeeJaehoon on 2024/01/05.
//

import Foundation
import Combine

class ImageResultViewModel: ViewModelType {

    struct Input {
        var searchImage: AnyPublisher<String, Never>
    }

    struct Output {
        var fetchFail: AnyPublisher<Error, Never>
        var moreButtonisEnd: AnyPublisher<Void, Never>
        var fetchImageResult: AnyPublisher<[ImageResult], Never>
    }

    private let apiService: APIService
    private var cancellable = Set<AnyCancellable>()

    // with api
    private var page: Int = 1

    // output
    private let errorSubject: PassthroughSubject<Error, Never> = .init()
    private let moreButtonisEndSubject: PassthroughSubject<Void, Never> = .init()
    private let imageResultSubject: PassthroughSubject<[ImageResult], Never> = .init()

    init(apiService: APIService = APIService()) {
        self.apiService = apiService
    }

    func transform(input: Input) -> Output {
        input.searchImage
            .sink { [weak self] inputWord in
                self?.handleGetImageSearchResult(query: inputWord)
            }
            .store(in: &cancellable)

        return Output(fetchFail: errorSubject.eraseToAnyPublisher(),
                      moreButtonisEnd: moreButtonisEndSubject.eraseToAnyPublisher(),
                      fetchImageResult: imageResultSubject.eraseToAnyPublisher())
    }

    private func handleGetImageSearchResult(query: String) {
        if query.isEmpty {
            self.imageResultSubject.send([])
            return
        }
        
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String else { return }

        guard let url = EndPoint.image(query: query, page: self.page).url else {
            self.errorSubject.send(APIError.invalidURL)
            return
        }

        var request = URLRequest (url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = ["Authorization": "KakaoAK \(apiKey)"]

        apiService.getFetchResult(type: ImageSearch.self, request: request)
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

                if let imageResultList = result.imageResults {
                    self?.imageResultSubject.send(imageResultList)
                }
            }.store(in: &cancellable)
    }

}
