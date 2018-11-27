//
//  LinuxMain.swift.swift
//  mservice-cachewarmer
//
//  Copyright © 2018 Christopher Reitz. Licensed under the MIT license.
//  See LICENSE file in the project root for full license information.
//

import XCTest
@testable import AppTests

XCTMain([
	testCase(CacheWarmerServiceTests.allTests),
	testCase(RunInformationServiceTests.allTests),
    testCase(NightWatchmanServiceTests.allTests)
])
