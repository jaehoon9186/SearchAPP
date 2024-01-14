//
//  CollectionCellViewModel.swift
//  SearchApp
//
//  Created by LeeJaehoon on 2024/01/09.
//

import UIKit
import Combine

class CollectionCellViewModel {
    enum Input {
        case requestImage(urlStr: String)
    }

    enum Output {
        case fetchUIImage(image: UIImage?)
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
                case .requestImage(let urlStr):
                    self?.handleGetImage(url: URL(string: urlStr.encodeURL()!))
                }
            }
            .store(in: &cancellables)

        return output.eraseToAnyPublisher()
    }

    private func handleGetImage(url: URL?) {

        apiService.getFetchImage(url: url!)
            .sink { completion in
                switch completion {
                case .failure(_):
                    break
                case .finished: break
                }
            } receiveValue: { [weak self] uiImage in
                self?.output.send(.fetchUIImage(image: uiImage))
            }
            .store(in: &cancellables)
    }
}
