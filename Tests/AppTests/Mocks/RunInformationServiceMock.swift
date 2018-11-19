//
//  RunInformationServiceMock.swift
//  mservice-cachewarmer
//
//  Copyright © 2018 Christopher Reitz. Licensed under the MIT license.
//  See LICENSE file in the project root for full license information.
//

@testable import App

class RunInformationServiceMock: RunInformationServiceType {

    // MARK: - Call counter

    var updateCalled = 0

    // MARK: - RunInformationServiceType

    var description: String { return "" }

    func update(duration: Int) {
        updateCalled += 1
    }
}
