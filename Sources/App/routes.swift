//
//  routes.swift
//  mservice-cachewarmer
//
//  Copyright © 2018 Christopher Reitz. Licensed under the MIT license.
//  See LICENSE file in the project root for full license information.
//

import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    router.get { req -> String in
        return try req.sharedContainer.make(RunInformationService.self).description
    }
}
