//
//  APIError.swift
//  SearchApp
//
//  Created by LeeJaehoon on 2023/12/04.
//

import Foundation


enum APIError: Error, CustomStringConvertible {

    case invalidURL
    case invalidRequest
    case transportError(Error)
    case badResponse(stateCode: Int)
    case missingData
    case parsingError
    case coreDataError
    case unknown

    var localizedDescription: String {
        // 사용자에게
        switch self {
        case .badResponse(_):
            return "죄송합니다. 서버에 문제가 있습니다."
        case .invalidURL, .invalidRequest, .transportError(_), .parsingError:
            return "죄송합니다. 문제가 발생했습니다."
        case .missingData:
            return "요청하신 결과가 없습니다."
        case .coreDataError:
            return "코어데이터 에러"
        case .unknown:
            return "관리자에게 문의하세요"
        }
    }

    // CustomStringConvertible 채택
    var description: String {
        // 디버깅
        switch self {
        case .invalidURL:
            return "ERROR: 유효하지 않은 URL"
        case .invalidRequest:
            return "ERROR: 유효하지 않은 request"
        case .transportError(error: let error):
            return "ERROR: API 요청 실패, \(error)"
        case .badResponse(stateCode: let stateCode):
            return "ERROR: 서버에러 \(stateCode)"
        case .missingData:
            return "ERROR: 데이터 없음"
        case .parsingError:
            return "ERROR: data parsing 실패"
        case .coreDataError:
            return "ERROR: CoreData Error"
        case .unknown:
            return "ERROR: 기타 에러"
        }
    }
}
