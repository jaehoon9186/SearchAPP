//
//  ViewModelType.swift
//  SearchApp
//
//  Created by LeeJaehoon on 2024/02/06.
//

import Foundation

protocol ViewModelType {
    associatedtype Input
    associatedtype Output

    func transform(input: Input) -> Output
}
