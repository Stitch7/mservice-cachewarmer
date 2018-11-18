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

    /// Register RunInformationService
    let runInformationService = RunInformationService()
    services.register(runInformationService, as: RunInformationService.self)

    /// Register middleware
    var middlewares = MiddlewareConfig()
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    /// Setup server
    let serverConfig = NIOServerConfig.default(hostname: "0.0.0.0", port: 9090)
    services.register(serverConfig)
}
