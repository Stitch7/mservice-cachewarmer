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
        container = try! Application()
    }

    // MARK: - Client

    var container: Container

    func send(_ req: Request) -> EventLoopFuture<Response> {
        let jsonString = readTestJsonFile(for: req.http.urlString)

        let response = Response(using: container)
        response.http.headers = ["Content-Type": "application/json; charset=utf-8"]
        response.http.body = HTTPBody(string: jsonString)

        let promise = req.eventLoop.newPromise(Response.self)
        promise.succeed(result: response)

        return promise.futureResult
    }

    // MARK: - Helper

    func readTestJsonFile(for urlString: String) -> String {
        var jsonString: String
        switch true {
        case urlString == "/boards":
            jsonString = readTestJsonFile(name: "boards")
            boardsRouteCalled += 1
        case urlString.hasSuffix("/threads"):
            jsonString = readTestJsonFile(name: "threads")
            threadsRouteCalled += 1
        case urlString.hasPrefix("/board/"):
            jsonString = readTestJsonFile(name: "messages")
            messagesRouteCalled += 1
        default:
            fatalError("Uncovered url occured")
        }

        return jsonString
    }

    func readTestJsonFile(name: String) -> String {
        let filepath = Bundle(for: ClientMock.self).path(forResource: name, ofType: "json")!
        return try! String(contentsOfFile: filepath)
    }
}
