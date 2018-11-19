//
//  RunInformationService.swift
//  mservice-cachewarmer
//
//  Copyright © 2018 Christopher Reitz. Licensed under the MIT license.
//  See LICENSE file in the project root for full license information.
//

import Vapor

protocol RunInformationServiceType: CustomStringConvertible, Service {
    func update(duration: Int)
}

final class RunInformationService: RunInformationServiceType {

    // MARK: - RunCounter container

    struct RunCounter {
        private(set) var numberOfRuns: UInt64 = 0

        mutating func increment() {
            if numberOfRuns < UInt64.max {
                numberOfRuns += 1
            }
        }
    }

    // MARK: - Properties

    private(set) var lastRun: Date?
    private(set) var lastRunDuration: Int = -1
    private(set) var runningSince = Date()
    private(set) var longestRunDuration: Int = -1
    private(set) var runCounter = RunCounter()

    private(set) var dateFormatter: DateFormatter = {
        guard let timeZone = TimeZone(identifier: "Europe/Berlin") else {
            fatalError("TimeZone not found on System")
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy, HH:mm"
        dateFormatter.timeZone = timeZone
        return dateFormatter
    }()

    var runningSinceFormatted: String {
        return dateFormatter.string(from: runningSince)
    }

    var lastRunFormatted: String {
        return dateFormatter.string(from: lastRun ?? runningSince)
    }

    // MARK: - CustomStringConvertible

    var description: String {
        let pad: (String) -> String = { $0.padding(toLength: 20, withPad: " ", startingAt: 0) }
        let infos = [
            ".---------------------------------------------.",
            "| m!service cachewarmer runtime information   |",
            "|---------------------------------------------|",
            "| Running since        | \(pad(runningSinceFormatted)) |",
            "| Last run             | \(pad(lastRunFormatted)) |",
            "| Last duration        | \(pad((String(lastRunDuration) + " sec"))) |",
            "| Longest duration     | \(pad((String(longestRunDuration) + " sec"))) |",
            "| Total number of runs | \(pad(String(runCounter.numberOfRuns))) |",
            "·---------------------------------------------·"
        ]

        return infos.joined(separator: "\n")
    }

    // MARK: - Initializers

    init() { }

    init(runCounter: RunCounter) {
        self.runCounter = runCounter
    }

    // MARK: - Public

    func update(duration: Int) {
        lastRun = Date()
        lastRunDuration = duration
        runCounter.increment()
        if duration > longestRunDuration {
            longestRunDuration = duration
        }
    }
}
