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
    }

    enum Output {
        case fetchFail(error: Error)
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
            }
        }.store(in: &cancellables)

        return output.eraseToAnyPublisher()
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
}
