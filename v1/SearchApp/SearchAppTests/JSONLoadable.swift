//
//  JSONLoadable.swift
//  SearchAppTests
//
//  Created by LeeJaehoon on 2024/02/23.
//

import Foundation

protocol JSONLoadable: AnyObject {
    var bundle: Bundle { get }
    func loadJSON(filename: String) -> Data
}

extension JSONLoadable {
    var bundle: Bundle {
        return Bundle(for: type(of: self))
    }

    func loadJSON(filename: String) -> Data {
        guard let path = bundle.url(forResource: filename, withExtension: "json") else {
            fatalError("Failed to load JSON file.")
        }

        do {
            let data = try Data(contentsOf: path)
            return data
        } catch {
            fatalError("Failed to decode the JSON.")
        }
    }
}
