//
//  configure.swift
//  mservice-cachewarmer
//
//  Copyright © 2018 Christopher Reitz. Licensed under the MIT license.
//  See LICENSE file in the project root for full license information.
//

import Vapor

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Set time zone
    let timeZoneIdentifier = Environment.get("TIMEZONE") ?? "Europe/Berlin"
    let timeZone = TimeZone(identifier: timeZoneIdentifier)!

    /// Register RunInformationService
    let runInformationService = RunInformationService(timeZone: timeZone)
    services.register(runInformationService, as: RunInformationService.self)

    /// Register NightWatchmanService
    var startHour = 2
    if let envStartHourStr = Environment.get("START"), let envStartHour = Int(envStartHourStr) {
        startHour = envStartHour
    }
    var endHour = 5
    if let envEndHourStr = Environment.get("END"), let envEndHour = Int(envEndHourStr) {
        endHour = envEndHour
    }
    let nightWatchmanService = NightWatchmanService(timeZone: timeZone, startHour: startHour, endHour: endHour)
    services.register(nightWatchmanService, as: NightWatchmanService.self)

    /// Register middleware
    var middlewares = MiddlewareConfig()
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    /// Setup server
    var port = 9090
    if let envPortStr = Environment.get("PORT"), let envPort = Int(envPortStr) {
        port = envPort
    }
    let serverConfig = NIOServerConfig.default(hostname: "0.0.0.0", port: port)
    services.register(serverConfig)
}
