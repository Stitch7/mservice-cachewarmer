//
//  CacheWarmerServiceTests.swift
//  mservice-cachewarmer
//
//  Copyright © 2018 Christopher Reitz. Licensed under the MIT license.
//  See LICENSE file in the project root for full license information.
//

import XCTest
@testable import App

final class CacheWarmerServiceTests: XCTestCase {

    // MARK: - Reused initializations

    let client = ClientMock()
    let logger = LoggerMock()
    let runInformationService = RunInformationServiceMock()
    let testBoardsCount = 6

    // MARK: - Test cases

    func test() throws {
        let didFinishExpectation = expectation(description: "CacheWarmerServiceRunDidFinish")

        let service = CacheWarmerService(log: logger,
                                         httpClient: client,
                                         runInformationService: runInformationService,
                                         baseURL: "")
        service.run { _ in
            didFinishExpectation.fulfill()
        }

        waitForExpectations(timeout: 3)

        XCTAssertEqual(runInformationService.updateCalled, 1)
        XCTAssertEqual(client.boardsRouteCalled, 1)
        XCTAssertEqual(client.threadsRouteCalled, testBoardsCount)
        XCTAssertEqual(client.messagesRouteCalled, testBoardsCount * service.fetchNumberOfThreads)
    }

    // MARK: - Helper<

    static let allTests = [
        ("test", test)
    ]
}
