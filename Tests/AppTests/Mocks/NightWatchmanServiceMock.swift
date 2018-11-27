//
//  NightWatchmanServiceMock.swift
//  mservice-cachewarmer
//
//  Copyright © 2018 Christopher Reitz. Licensed under the MIT license.
//  See LICENSE file in the project root for full license information.
//

import Foundation
@testable import App

class NightWatchmanServiceMock: NightWatchmanServiceType {

    // MARK: - Call counter

    var entranceAllowedCalled = 0

    // MARK: - Properties

    let shouldAllow: Bool

    // MARK: - Initializers

    init(shouldAllow: Bool) {
        self.shouldAllow = shouldAllow
    }

    // MARK: - NightWatchmanServiceType

    func entranceAllowed(on date: Date = Date()) -> Bool {
        entranceAllowedCalled += 1
        return shouldAllow
    }
}
