//
//  SearchViewModel.swift
//  SearchApp
//
//  Created by LeeJaehoon on 2023/12/08.
//

import Foundation
import Combine

class SearchViewModel {
    enum Input {
        case webButtonTap(query: String, page: Int = 1)
        case imageButtonTap(query: String, page: Int = 1)
        case videoButtonTap(query: String, page: Int = 1)
    }

    enum Output {
        case fetchFail(error: APIError)
        case fetchWebSucceed(result: WebSearch, nowPage: Int)
        case fetchImageSucceed(result: ImageSearch, nowPage: Int)
        case fetchVideoSucceed(result: VideoSearch, nowPage: Int)
    }

    private let apiService: APIService
    private let output: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()

    init(apiService: APIService = APIService()) {
        self.apiService = apiService
    }

    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {

        input.sink { [weak self] event in
            switch event {
            case .webButtonTap(let query, let page):
                self?.handleGetSearchResult(type: WebSearch.self, url: EndPoint.web(query: query, page: page).url, nowPage: page)
            case .imageButtonTap(let query, let page):
                self?.handleGetSearchResult(type: ImageSearch.self, url: EndPoint.image(query: query, page: page).url, nowPage: page)
            case .videoButtonTap(let query, let page):
                self?.handleGetSearchResult(type: VideoSearch.self, url: EndPoint.video(query: query, page: page).url, nowPage: page)
            }
        }.store(in: &cancellables)

        return output.eraseToAnyPublisher()
    }

    func handleGetSearchResult<T: Decodable>(type: T.Type, url: URL?, nowPage: Int) {

        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String else { return }

        var request = URLRequest (url: url!)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = ["Authorization": "KakaoAK \(apiKey)"]

        apiService.getFetchResult(type: type, request: request).sink { completion in
            switch completion {
            case .failure(let error):
                print(error.localizedDescription, "에러 .. 떳나")
            case .finished:
                print("끝 성공했나. ")
            }
        } receiveValue: { [weak self] result in
            switch type {
            case is WebSearch.Type:
                print("output send 했나")
                self?.output.send(Output.fetchWebSucceed(result: result as! WebSearch, nowPage: nowPage))
            case is ImageSearch.Type:
                self?.output.send(Output.fetchImageSucceed(result: result as! ImageSearch, nowPage: nowPage))
            case is VideoSearch.Type:
                self?.output.send(Output.fetchVideoSucceed(result: result as! VideoSearch, nowPage: nowPage))
            default:
                print("반환 타입이 옳바르지 않습니다. ")
            }
        }.store(in: &cancellables)

    }

}
