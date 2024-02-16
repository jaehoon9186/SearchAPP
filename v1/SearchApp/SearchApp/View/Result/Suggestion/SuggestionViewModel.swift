//
//  SuggestionViewModel.swift
//  SearchApp
//
//  Created by LeeJaehoon on 2024/02/06.
//

import Foundation
import Combine

class SuggestionViewModel: ViewModelType {

    struct Input {
        var searchWord: AnyPublisher<String, Never>
        var recordRemoveButtonTap: AnyPublisher<SearchRecord, Never>
    }

    struct Output {
        var fetchFail: AnyPublisher<Error, Never>
        var fetchRecords: AnyPublisher<[SearchRecord], Never>
        var fetchSuggestion: AnyPublisher<Suggestion, Never>
    }

    private var cancellable = Set<AnyCancellable>()
    private let apiService: APIService

    // output
    private let errorSubject: PassthroughSubject<Error, Never> = .init()
    private let recordsSubject: PassthroughSubject<[SearchRecord], Never> = .init()
    private let SuggestionSubject: PassthroughSubject<Suggestion, Never> = .init()

    init(apiService: APIService = APIService()) {
        self.apiService = apiService
    }

    func transform(input: Input) -> Output {
        input.recordRemoveButtonTap.sink { [weak self] searchRecord in
            self?.removeOneRecord(object: searchRecord)
        }.store(in: &cancellable)

        input.searchWord
            .sink { [weak self] inputWord in
                self?.handleGetRecordWords(query: inputWord)
                self?.handleGetSuggestion(query: inputWord)
            }
            .store(in: &cancellable)

        return Output(fetchFail: errorSubject.eraseToAnyPublisher(),
                      fetchRecords: recordsSubject.eraseToAnyPublisher(),
                      fetchSuggestion: SuggestionSubject.eraseToAnyPublisher())
    }

    private func handleGetSuggestion(query: String) {
        let str = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if str.isEmpty {
            self.SuggestionSubject.send(Suggestion(suggestedWords: []))
            return
        }

        let urlStr = "https://suggestqueries.google.com/complete/search?output=toolbar&hl=kor&q=\(str)"
        let url = URL(string: urlStr.encodeURL()!)


        apiService.getFetchSuggestion(url: url).sink { [weak self] completion in
            switch completion {
            case .failure(let error):
                self?.errorSubject.send(error)
            case .finished: break
            }
        } receiveValue: { [weak self] suggestion in
            self?.SuggestionSubject.send(suggestion)
        }.store(in: &cancellable)
    }

    private func handleGetRecordWords(query: String) {
        let str = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let count = str.isEmpty ? 10 : 3

        do {
            try CoreDataManager.shard.readRecord().publisher
                .sink { [weak self] records in
                    var result = records.filter { $0.word!.hasPrefix(str) }
                    result = zip(result, (0..<count)).map { $0.0 }
                    self?.recordsSubject.send(result)
                }.store(in: &cancellable)
        } catch {
            self.errorSubject.send(error)
        }
    }

    private func removeOneRecord(object: SearchRecord) {
        do {
            try CoreDataManager.shard.deleteObject(object: object)
        } catch {
            self.errorSubject.send(error)
        }
    }

    // 미사용
    private func removeAllRecordWords() {
        do {
            try CoreDataManager.shard.deleteAll()
        } catch {
            self.errorSubject.send(error)
        }
    }
}
