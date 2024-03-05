//
//  SearchAppAPIServiceTests.swift
//  SearchAppTests
//
//  Created by LeeJaehoon on 2024/02/22.
//

import XCTest
import Combine
import UIKit
@testable import SearchApp


// using Mock Session
final class APIServiceTests: XCTestCase {

    var sut: APIServiceProtocol!

    override func tearDown() {
        sut = nil
    }

    // 원하는 객체에 값을 담아 반환하는지?
    // statusCode가 200번대가 아닐때 백엔드 문제일때 테스트, 원하는 fail값을 반환하는지?
    func test_fetchSearch_withVaildRequest_ExpextedWebResultsCount_3() {
        // given
        sut = APIService(session: MockURLSession(lastRequestMethod: .fetchSearch, makeRequestFail: false))

        // when
        let sub = sut.getFetchSearch(type: WebSearch.self, request: URLRequest(url: URL(string: "www.test.com")!))
            .sink { completion in
                switch completion {
                case .finished:
                    print("finished")
                case .failure(let error):
                    print("error: \(error)")
                }
            } receiveValue: { webSearch in
                print("result: ", webSearch.webResults!.count)
                // then
                XCTAssertEqual(webSearch.webResults!.count, 3, "3개가 나와야함.")
            }
    }

    func test_fetchSearch_withRequestFail_Expected_Error() {
        // given
        sut = APIService(session: MockURLSession(lastRequestMethod: .fetchSearch, makeRequestFail: true))

        // when
        var receivedError: Error?
        let sub = sut.getFetchSearch(type: WebSearch.self, request: URLRequest(url: URL(string: "www.test.com")!))
            .sink { completion in
                switch completion {
                case .finished:
                    XCTFail("Fail")
                case .failure(let error):
                    receivedError = error
                }
            } receiveValue: { webSearch in
                XCTFail("Fail")
            }

        // then
        XCTAssertNotNil(receivedError)
    }

    func test_fetchImage_vaildRequest_expected_getImage() {
        // given
        sut = APIService(session: MockURLSession(lastRequestMethod: .fetchImage, makeRequestFail: false))

        // when
        var receivedImage: UIImage?
        let sub = sut.getFetchImage(url: URL(string: "www.test.com")!)
            .sink { completion in
                switch completion {
                case .finished:
                    print("finished")
                case .failure(_):
                    XCTFail("Fail")
                }
            } receiveValue: { image in
                receivedImage = image
            }

        // then
        XCTAssertNotNil(receivedImage)
    }

}

