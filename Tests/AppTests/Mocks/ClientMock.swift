//
//  ClientMock.swift
//  mservice-cachewarmer
//
//  Copyright © 2018 Christopher Reitz. Licensed under the MIT license.
//  See LICENSE file in the project root for full license information.
//

import Vapor

class ClientMock: Client {

    // MARK: - Call counter

    var boardsRouteCalled = 0
    var threadsRouteCalled = 0
    var messagesRouteCalled = 0

    // MARK: - Initializers

    init() {
        // swiftlint:disable force_try
        container = try! Application()
        // swiftlint:enable force_try
    }

    // MARK: - Client

    var container: Container

    func send(_ req: Request) -> EventLoopFuture<Response> {
        let jsonString = testJson(for: req.http.urlString)

        let response = Response(using: container)
        response.http.headers = ["Content-Type": "application/json; charset=utf-8"]
        response.http.body = HTTPBody(string: jsonString)

        let promise = req.eventLoop.newPromise(Response.self)
        promise.succeed(result: response)

        return promise.futureResult
    }

    // MARK: - Helper

    func testJson(for urlString: String) -> String {
        var jsonString: String
        switch true {
        case urlString == "/boards":
            jsonString = boardsJSON
            boardsRouteCalled += 1
        case urlString.hasSuffix("/threads"):
            jsonString = threadsJSON
            threadsRouteCalled += 1
        case urlString.hasPrefix("/board/"):
            jsonString = messagesJSON
            messagesRouteCalled += 1
        default:
            fatalError("Uncovered url occured")
        }

        return jsonString
    }
}
