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
        case searchTap(word: String)
        case searchingGetRecord(query: String) // 검색 기록
        case searchingGetSuggestion(query: String) // 추천 검색
        case recordRemoveButtonTap(object: SearchRecord) // 검색 기록 cell 삭제
    }

    enum Output {
        case fetchFail(error: Error)
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
            case .searchTap(let word):
                self?.saveRecordWord(query: word)
            case .searchingGetRecord(let query):
                self?.handleGetRecordWords(query: query)
            case .searchingGetSuggestion(let query):
                self?.handleGetSuggestion(query: query)
            case .recordRemoveButtonTap(let object):
                self?.removeOneRecord(object: object)
            }
        }.store(in: &cancellables)

        return output.eraseToAnyPublisher()
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

    private func removeOneRecord(object: SearchRecord) {
        do {
            try CoreDataManager.shard.deleteObject(object: object)
        } catch {
            output.send(.fetchFail(error: error))
        }
    }

    // 미사용
    private func removeAllRecordWords() {
        do {
            try CoreDataManager.shard.deleteAll()
        } catch {
            output.send(.fetchFail(error: error))
        }
    }
}
