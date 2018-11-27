//
//  RunInformationServiceTests.swift
//  mservice-cachewarmer
//
//  Copyright © 2018 Christopher Reitz. Licensed under the MIT license.
//  See LICENSE file in the project root for full license information.
//

import XCTest
@testable import App

final class RunInformationServiceTests: XCTestCase {

    // MARK: - Reused initializations
    let testDuration = 23
    let higherTestDuration = 42
    let timeZone = TimeZone(identifier: "Europe/Berlin")!

    // MARK: - Test cases

    func testInitialState() throws {
        let service = RunInformationService(timeZone: timeZone)
        assertDescription(for: service, lastRunDuration: -1, longestRunDuration: -1, numberOfRuns: 0)
    }

    func testFirstUpdate() throws {
        let service = RunInformationService(timeZone: timeZone)
        service.update(duration: testDuration)

        assertDescription(for: service,
                          lastRunDuration: testDuration,
                          longestRunDuration: testDuration,
                          numberOfRuns: 1)
    }

    func testSecondUpdateWithHigherDuration() throws {
        let service = RunInformationService(timeZone: timeZone)
        service.update(duration: testDuration)
        service.update(duration: higherTestDuration)

        assertDescription(for: service,
                          lastRunDuration: higherTestDuration,
                          longestRunDuration: higherTestDuration,
                          numberOfRuns: 2)
    }

    func testThirdUpdateWithLowerDuration() throws {
        let service = RunInformationService(timeZone: timeZone)
        service.update(duration: testDuration)
        service.update(duration: higherTestDuration)
        service.update(duration: testDuration)

        assertDescription(for: service,
                          lastRunDuration: testDuration,
                          longestRunDuration: higherTestDuration,
                          numberOfRuns: 3)
    }

    func testDontOverflowMaxRuns() throws {
        let nearlyOverflowedRunCounter = RunInformationService.RunCounter(numberOfRuns: UInt64.max)
        let service = RunInformationService(timeZone: timeZone, runCounter: nearlyOverflowedRunCounter)
        service.update(duration: testDuration)

        assertDescription(for: service,
                          lastRunDuration: testDuration,
                          longestRunDuration: testDuration,
                          numberOfRuns: UInt64.max)
    }

    // MARK: - Helper

    private func assertDescription(for service: RunInformationService,
                                   lastRunDuration: Int,
                                   longestRunDuration: Int,
                                   numberOfRuns: UInt64
    ) {
        let serviceDesc = service.description
        XCTAssertTrue(serviceDesc.range(of: "Running since        | \(service.runningSinceFormatted)") != nil)
        XCTAssertTrue(serviceDesc.range(of: "Last run             | \(service.lastRunFormatted)") != nil)
        XCTAssertTrue(serviceDesc.range(of: "Last duration        | \(lastRunDuration)") != nil)
        XCTAssertTrue(serviceDesc.range(of: "Longest duration     | \(longestRunDuration)") != nil)
        XCTAssertTrue(serviceDesc.range(of: "Total number of runs | \(numberOfRuns)") != nil)
    }

    static let allTests = [
        ("testInitialState", testInitialState),
        ("testFirstUpdate", testFirstUpdate),
        ("testThirdUpdateWithLowerDuration", testThirdUpdateWithLowerDuration),
        ("testDontOverflowMaxRuns", testDontOverflowMaxRuns)
    ]
}
