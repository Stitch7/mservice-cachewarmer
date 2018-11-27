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

    let logger = LoggerMock()
    let client = ClientMock()
    let runInformationService = RunInformationServiceMock()
    let testBoardsCount = 6

    // MARK: - Test cases

    func testFullRun() throws {
        let didFinishExpectation = expectation(description: "CacheWarmerServiceRunDidFinish")

        let nightWatchmanService = NightWatchmanServiceMock(shouldAllow: true)
        let service = CacheWarmerService(log: logger,
                                         httpClient: client,
                                         runInformationService: runInformationService,
                                         nightWatchmanService: nightWatchmanService,
                                         baseURL: "")
        service.run { succeed, duration in
            XCTAssertTrue(succeed)
            XCTAssertNotNil(duration)
            didFinishExpectation.fulfill()
        }

        waitForExpectations(timeout: 3)

        XCTAssertEqual(runInformationService.updateCalled, 1)
        XCTAssertEqual(nightWatchmanService.entranceAllowedCalled, 1)
        XCTAssertEqual(client.boardsRouteCalled, 1)
        XCTAssertEqual(client.threadsRouteCalled, testBoardsCount)
        XCTAssertEqual(client.messagesRouteCalled, testBoardsCount * service.fetchNumberOfThreads)
    }

    func testDontRunDuringNightTime() throws {
        let didFinishExpectation = expectation(description: "CacheWarmerServiceRunDidFinish")

        let nightWatchmanService = NightWatchmanServiceMock(shouldAllow: false)
        let service = CacheWarmerService(log: logger,
                                         httpClient: client,
                                         runInformationService: runInformationService,
                                         nightWatchmanService: nightWatchmanService,
                                         baseURL: "")
        service.run { succeed, _ in
            XCTAssertFalse(succeed)
            didFinishExpectation.fulfill()
        }

        waitForExpectations(timeout: 3)

        XCTAssertEqual(runInformationService.updateCalled, 0)
        XCTAssertEqual(nightWatchmanService.entranceAllowedCalled, 1)
        XCTAssertEqual(client.boardsRouteCalled, 0)
        XCTAssertEqual(client.threadsRouteCalled, 0)
        XCTAssertEqual(client.messagesRouteCalled, 0)
    }

    func testDontRunTwice() throws {
        let didFinishExpectation = expectation(description: "CacheWarmerServiceRunDidFinish")

        let nightWatchmanService = NightWatchmanServiceMock(shouldAllow: true)
        let service = CacheWarmerService(log: logger,
                                         httpClient: client,
                                         runInformationService: runInformationService,
                                         nightWatchmanService: nightWatchmanService,
                                         baseURL: "")
        service.run { succeed, _ in
            XCTAssertTrue(succeed)

            service.run { succeed, _ in
                XCTAssertFalse(succeed)
                didFinishExpectation.fulfill()
            }
        }

        waitForExpectations(timeout: 3)

        XCTAssertEqual(runInformationService.updateCalled, 1)
        XCTAssertEqual(nightWatchmanService.entranceAllowedCalled, 2)
        XCTAssertEqual(client.boardsRouteCalled, 1)
        XCTAssertEqual(client.threadsRouteCalled, testBoardsCount)
        XCTAssertEqual(client.messagesRouteCalled, testBoardsCount * service.fetchNumberOfThreads)
    }

    // MARK: - Helper

    static let allTests = [
        ("testFullRun", testFullRun),
        ("testDontRunDuringNightTime", testDontRunDuringNightTime),
        ("testDontRunTwice", testDontRunTwice)
    ]
}
