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
        case searchingGetRecord(query: String) // 검색 기록
        case searchingGetSuggestion(query: String) // 추천 검색
        case recordRemoveButtonTap(object: SearchRecord) // 검색 기록 cell 삭제
    }

    enum Output {
        case fetchFail(error: Error)
        case fetchWebSucceed(result: WebSearch, nowPage: Int)
        case fetchImageSucceed(result: ImageSearch, nowPage: Int)
        case fetchVideoSucceed(result: VideoSearch, nowPage: Int)
        case fetchSuggestionSucceed(result: Suggestion)
        case fetchRelatedRecordSucceed(result: [SearchRecord])
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
            case .webButtonTap(let query, let page):
                self?.saveRecordWord(query: query)
                self?.handleGetSearchResult(type: WebSearch.self, url: EndPoint.web(query: query, page: page).url, nowPage: page)

            case .imageButtonTap(let query, let page):
                self?.saveRecordWord(query: query)
                self?.handleGetSearchResult(type: ImageSearch.self, url: EndPoint.image(query: query, page: page).url, nowPage: page)

            case .videoButtonTap(let query, let page):
                self?.saveRecordWord(query: query)
                self?.handleGetSearchResult(type: VideoSearch.self, url: EndPoint.video(query: query, page: page).url, nowPage: page)

            case .searchingGetRecord(let query):
                self?.handleGetRecordWords(query: query)
            case .searchingGetSuggestion(let query):
                self?.handleGetSuggestion(query: query)
            case .recordRemoveButtonTap(let object):
                // 리무빙.
                print("삭제 \(object)")
            }
        }.store(in: &cancellables)

        return output.eraseToAnyPublisher()
    }

    private func handleGetSearchResult<T: Decodable>(type: T.Type, url: URL?, nowPage: Int) {

        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String else { return }

        var request = URLRequest (url: url!)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = ["Authorization": "KakaoAK \(apiKey)"]

        apiService.getFetchResult(type: type, request: request)
            .sink { [weak self] completion in
            switch completion {
            case .failure(let error):
                self?.output.send(Output.fetchFail(error: error))
            case .finished: break
            }
        } receiveValue: { [weak self] result in
            switch type {
            case is WebSearch.Type:
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

    private func handleGetSuggestion(query: String) {
        let str = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if str.isEmpty {
            self.output.send(.fetchSuggestionSucceed(result: Suggestion(suggestedWords: [])))
            return
        }

        let urlStr = "https://suggestqueries.google.com/complete/search?output=toolbar&hl=kor&q=\(str)"
        let url = URL(string: urlStr.encodeURL()!)

        apiService.getFetchSuggestion(url: url).sink { [weak self] completion in
            switch completion {
            case .failure(let error):
                self?.output.send(.fetchFail(error: error))
            case .finished: break
            }
        } receiveValue: { [weak self] suggestion in
            self?.output.send(.fetchSuggestionSucceed(result: suggestion))
        }.store(in: &cancellables)
    }

    private func handleGetRecordWords(query: String) {
        let str = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let count = str.isEmpty ? 10 : 3

        do {
            try CoreDataManager.shard.readRecord().publisher
                .sink { [weak self] records in
                    var result = records.filter { $0.word!.hasPrefix(str) }
                    result = zip(result, (0..<count)).map { $0.0 }
                    self?.output.send(.fetchRelatedRecordSucceed(result: result))
                }.store(in: &cancellables)
        } catch {
            output.send(.fetchFail(error: error))
        }
    }

    private func saveRecordWord(query: String) {
        let str = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if str.isEmpty {
            return
        }

        do {
            try CoreDataManager.shard.saveRecord(word: str)
        } catch {
            output.send(.fetchFail(error: error))
        }
    }

    private func removeAllRecordWords() {
        do {
            try CoreDataManager.shard.deleteAll()
        } catch {
            output.send(.fetchFail(error: error))
        }
    }
}
