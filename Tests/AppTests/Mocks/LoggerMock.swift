//
//  LoggerMock.swift
//  mservice-cachewarmer
//
//  Copyright © 2018 Christopher Reitz. Licensed under the MIT license.
//  See LICENSE file in the project root for full license information.
//

import Vapor

class LoggerMock: Logger {

    // MARK: - Logger

    // swiftlint:disable function_parameter_count
    func log(_ string: String, at level: LogLevel, file: String, function: String, line: UInt, column: UInt) { }
}
