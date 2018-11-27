//
//  NightWatchmanServiceTests.swift
//  mservice-cachewarmer
//
//  Copyright © 2018 Christopher Reitz. Licensed under the MIT license.
//  See LICENSE file in the project root for full license information.
//

import XCTest
@testable import App

final class NightWatchmanServiceTests: XCTestCase {

    // MARK: - Reused initializations

    static var calendar = Calendar(identifier: .gregorian)
    static let timeZone = TimeZone(identifier: "Europe/Berlin")!

    override class func setUp() {
        calendar.timeZone = timeZone
    }

    // MARK: - Test cases

    func testDefaultHoursOnFullHours() throws {

        let nightWatchman = NightWatchmanService(timeZone: NightWatchmanServiceTests.timeZone, startHour: 2, endHour: 5)

        let cases = [
            (0, true),
            (1, true),
            (2, false),
            (3, false),
            (4, false),
            (5, true),
            (6, true),
            (7, true),
            (8, true),
            (9, true),
            (10, true),
            (11, true),
            (12, true),
            (13, true),
            (14, true),
            (15, true),
            (16, true),
            (17, true),
            (18, true),
            (19, true),
            (20, true),
            (21, true),
            (22, true),
            (23, true)
        ]

        cases.forEach { (hour, expected) in
            let testDate = NightWatchmanServiceTests.calendar.date(bySettingHour: hour,
                                                                   minute: 0,
                                                                   second: 0,
                                                                   of: Date())!
            let actual = nightWatchman.entranceAllowed(on: testDate)
            let message = expected ? "Test if allowed on hour \(hour):00" : "Test if not allowed on hour \(hour):00"
            XCTAssertEqual(actual, expected, message)
        }
    }

    func testDefaultHoursOnHalfHours() throws {
        let nightWatchman = NightWatchmanService(timeZone: NightWatchmanServiceTests.timeZone,
                                                 startHour: 2,
                                                 endHour: 5)

        let cases = [
            (0, true),
            (1, true),
            (2, false),
            (3, false),
            (4, false),
            (5, true),
            (6, true),
            (7, true),
            (8, true),
            (9, true),
            (10, true),
            (11, true),
            (12, true),
            (13, true),
            (14, true),
            (15, true),
            (16, true),
            (17, true),
            (18, true),
            (19, true),
            (20, true),
            (21, true),
            (22, true),
            (23, true)
        ]

        cases.forEach { (hour, expected) in
            let testDate = NightWatchmanServiceTests.calendar.date(bySettingHour: hour,
                                                                   minute: 30,
                                                                   second: 0,
                                                                   of: Date())!
            let actual = nightWatchman.entranceAllowed(on: testDate)
            let message = expected ? "Test if allowed on hour \(hour):30" : "Test if not allowed on hour \(hour):30"
            XCTAssertEqual(actual, expected, message)
        }
    }

    func testDefaultHoursOnOneMinuteBeforeFullHour() throws {
        let nightWatchman = NightWatchmanService(timeZone: NightWatchmanServiceTests.timeZone, startHour: 2, endHour: 5)

        let cases = [
            (0, true),
            (1, true),
            (2, false),
            (3, false),
            (4, false),
            (5, true),
            (6, true),
            (7, true),
            (8, true),
            (9, true),
            (10, true),
            (11, true),
            (12, true),
            (13, true),
            (14, true),
            (15, true),
            (16, true),
            (17, true),
            (18, true),
            (19, true),
            (20, true),
            (21, true),
            (22, true),
            (23, true)
        ]

        cases.forEach { (hour, expected) in
            let testDate = NightWatchmanServiceTests.calendar.date(bySettingHour: hour,
                                                                   minute: 59,
                                                                   second: 59,
                                                                   of: Date())!
            let actual = nightWatchman.entranceAllowed(on: testDate)
            let message = expected
                ? "Test if allowed on hour \(hour):59:59"
                : "Test if not allowed on hour \(hour):59:59"
            XCTAssertEqual(actual, expected, message)
        }
    }

    func testIndividualHours() throws {
        let nightWatchman = NightWatchmanService(timeZone: NightWatchmanServiceTests.timeZone,
                                                 startHour: 22,
                                                 endHour: 2)

        let cases = [
            (0, false),
            (1, false),
            (2, true),
            (3, true),
            (4, true),
            (5, true),
            (6, true),
            (7, true),
            (8, true),
            (9, true),
            (10, true),
            (11, true),
            (12, true),
            (13, true),
            (14, true),
            (15, true),
            (16, true),
            (17, true),
            (18, true),
            (19, true),
            (20, true),
            (21, true),
            (22, false),
            (23, false)
        ]

        cases.forEach { (hour, expected) in
            let testDate = NightWatchmanServiceTests.calendar.date(bySetting: .hour, value: hour, of: Date())!
            let actual = nightWatchman.entranceAllowed(on: testDate)
            let message = expected ? "Test if allowed on hour \(hour):00" : "Test if not allowed on hour \(hour):00"
            XCTAssertEqual(actual, expected, message)
        }
    }

    // MARK: - Helpers

    static let allTests = [
        ("testOnFullHour", testDefaultHoursOnFullHours),
        ("testOnHalfHour", testDefaultHoursOnHalfHours),
        ("testOnOneMinuteBeforeFullHour", testDefaultHoursOnOneMinuteBeforeFullHour),
        ("testIndividualHours", testIndividualHours)
    ]
}
