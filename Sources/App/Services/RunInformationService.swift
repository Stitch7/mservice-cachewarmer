//
//  RunInformationService.swift
//  mservice-cachewarmer
//
//  Copyright © 2018 Christopher Reitz. Licensed under the MIT license.
//  See LICENSE file in the project root for full license information.
//

import Vapor

final class RunInformationService: CustomStringConvertible, Service {

    // MARK: - Properties

    var lastRun: Date?
    var lastRunDuration: Int?

    private var runningSince: Date
    private var longestRunDuration: Int = 0
    private var numberOfRuns: Int64 = 0

    private var dateFormatter: DateFormatter = {
        guard let timeZone = TimeZone(identifier: "Europe/Berlin") else {
            fatalError("TimeZone not found on System")
        }

        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .short
        df.timeZone = timeZone
        return df
    }()

    // MARK: - CustomStringConvertible

    var description: String {
        let runningSinceFormatted = dateFormatter.string(from: runningSince)
        let lastRunFormatted = dateFormatter.string(from: lastRun ?? runningSince)
        let infos = [
            "m!service-cachewarmer runtime information",
            "-----------------------------------------",
            "Running since \(runningSinceFormatted)",
            "Last run: \(lastRunFormatted)",
            "Last duration: \(lastRunDuration ?? -1) seconds",
            "Longest duration: \(longestRunDuration) seconds",
            "Total number of runs: \(numberOfRuns)"
        ]

        return infos.joined(separator: "\n")
    }

    // MARK: - Initializers

    init() {
        runningSince = Date()
    }

    // MARK: - Public

    func update(duration: Int) {
        lastRun = Date()
        lastRunDuration = duration
        if numberOfRuns < Int64.max {
            numberOfRuns += 1
        }
        if duration > longestRunDuration {
            longestRunDuration = duration
        }
    }
}
