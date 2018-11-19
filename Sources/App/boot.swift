//
//  boot.swift
//  mservice-cachewarmer
//
//  Copyright © 2018 Christopher Reitz. Licensed under the MIT license.
//  See LICENSE file in the project root for full license information.
//

import Vapor
import Jobs

/// Called after your application has initialized.
public func boot(_ app: Application) throws {

    var defaultInterval: Double = 130
    if let enviromnentInterval = Environment.get("INTERVAL") {
        defaultInterval = Double(enviromnentInterval) ?? defaultInterval
    }

    var jobIsRunning = false
    let log = try app.make(Logger.self)
    let httpClient = try app.client()
    let runInformationService = try app.make(RunInformationService.self)
    let mserviceHost = Environment.get("MSERVICE_PORT_8080_TCP_ADDR") ?? "localhost"
    let mservicePort = Environment.get("MSERVICE_PORT_8080_TCP_PORT") ?? "8080"
    let cacheWarmer = CacheWarmerService(log: log,
                                         httpClient: httpClient,
                                         runInformationService: runInformationService,
                                         baseURL: "http://\(mserviceHost):\(mservicePort)")

    Jobs.add(interval: .seconds(defaultInterval)) {
        guard !jobIsRunning else {
            log.info("Skipping new run, because previous did not finished yet")
            return
        }

        log.info("Starting new run - \(Date())")
        jobIsRunning = true
        cacheWarmer.run { duration in
            jobIsRunning = false
        }
    }
}
