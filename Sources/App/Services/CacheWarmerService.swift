//
//  CacheWarmerService.swift
//  mservice-cachewarmer
//
//  Copyright © 2018 Christopher Reitz. Licensed under the MIT license.
//  See LICENSE file in the project root for full license information.
//

import Vapor

final class CacheWarmerService {

    // MARK: - Properties

    let log: Logger
    let httpClient: Client
    let runInformationService: RunInformationServiceType
    let baseURL: String
    let fetchNumberOfThreads: Int
    let dispatchGroup = DispatchGroup()
    let queue = DispatchQueue(label: "CacheWarmerQueue", qos: .background)
    var startTime = DispatchTime.now()

    // MARK: - Initializers

    init(log: Logger,
         httpClient: Client,
         runInformationService: RunInformationServiceType,
         baseURL: String,
         fetchNumberOfThreads: Int = 20
    ) {
        self.log = log
        self.httpClient = httpClient
        self.runInformationService = runInformationService
        self.baseURL = baseURL
        self.fetchNumberOfThreads = fetchNumberOfThreads

        log.info("CacheWarmerService initialized with baseUrl: \(baseURL)")
    }

    // MARK: - Public

    func run(didFinishBlock: @escaping (Double) -> Void) {
        startTime = DispatchTime.now()

        for board in fetchBoards() {
            guard let boardId = board.id else { continue }
            perform {
                let threads = self.fetchThreads(boardId: boardId)
                self.perform {
                    var i = 0
                    for thread in threads {
                        i += 1; if i > self.fetchNumberOfThreads { break }
                        self.fetchThread(boardId: boardId, threadId: thread.id)
                    }
                }
            }
        }

        dispatchGroup.notify(queue: queue) {
            let endTime = DispatchTime.now()
            let nanoTime = endTime.uptimeNanoseconds - self.startTime.uptimeNanoseconds
            let duration = Double(nanoTime) / 1_000_000_000

            self.runInformationService.update(duration: Int(duration))
            self.log.info("""
            \n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            finished job in \(duration) seconds
            ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n
            """)
            didFinishBlock(duration)
        }
    }

    // MARK: - Private

    private func perform(block: @escaping () -> Void) {
        dispatchGroup.enter()
        queue.asyncAfter(deadline: .now() + .milliseconds(500)) {
            block()
            self.dispatchGroup.leave()
        }
    }

    private func fetch(_ route: String) throws -> EventLoopFuture<Response> {
        log.info("fetching \(route)")
        return self.httpClient.get("\(baseURL)\(route)", headers: ["user-agent": "m!service-cachewarmer"])
    }

    private func fetchBoards() -> Boards {
        do {
            return try fetch("/boards").flatMap(to: Boards.self, { response in
                return try response.content.decode(Boards.self)
            }).wait().filter { $0.id != nil }
        } catch {
            log.report(error: error, verbose: true)
            return Boards()
        }
    }

    private func fetchThreads(boardId: Int) -> Threads {
        do {
            return try fetch("/board/\(boardId)/threads").flatMap(to: Threads.self, { response in
                return try response.content.decode(Threads.self)
            }).wait()
        } catch {
            log.report(error: error, verbose: true)
            return Threads()
        }
    }

    private func fetchThread(boardId: Int, threadId: Int) {
        do {
            _ = try fetch("/board/\(boardId)/thread/\(threadId)").wait()
        } catch {
            log.report(error: error, verbose: true)
        }
    }
}
